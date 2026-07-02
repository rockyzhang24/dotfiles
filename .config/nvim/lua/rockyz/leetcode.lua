--
-- Inspired by https://github.com/kawre/leetcode.nvim
--
-- Run command :LeetCode <url> [variant] <lang> and it will first create a directory specific this
-- question and then genreate two files:
-- (1). a md file containing question description
-- (2). a solution file with code snippet
--
-- The question description is always refreshed from LeetCode so the local markdown stays
-- synchronized with the lastest version.
--
-- For example, run :LeetCode https://leetcode.com/problems/two-sum/description/ method-1 js
--
--   - First, it creates a directory ~/oj/leetcode-js to store all javascript solutions if it does
--     not exist yet
--   - Next, it creates a sub-directory 1-two-sum for the solutions of this specific question
--   - Last, it genreates two files under this directory:
--      (1). 1-two-sum.md is the question description
--      (2). 1-two-sum-method-1.js has the template for us to write the solution
--
-- Keymap <Leader>ol (ol means oj leetcode) will try to fetch the question url from Chrome's current
-- tab or the system clipboard, and then insert partial command ":LeetCode <url> " in the command
-- line.
--

local io_utils = require('rockyz.utils.io')
local notify = require('rockyz.utils.notify')
local icons = require('rockyz.icons')

local config = {
    cookie_file = vim.env.HOME .. '/.config/leetcode-cookie',
    oj_dir = vim.env.HOME ..'/oj',
    graphql_url = 'https://leetcode.com/graphql/',
    referer = 'https://leetcode.com',
    origin = 'https://leetcode.com',
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
}

local cached_cookie

-- Graphql queries
local queries = {}

queries.question = [[
    query ($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
            id: questionId
            frontend_id: questionFrontendId
            title
            title_slug: titleSlug
            is_paid_only: isPaidOnly
            difficulty
            likes
            dislikes
            category_title: categoryTitle
            content
            mysql_schemas: mysqlSchemas
            data_schemas: dataSchemas
            code_snippets: codeSnippets {
                lang
                lang_slug: langSlug
                code
            }
            testcase_list: exampleTestcaseList
            meta_data: metaData
            ac_rate: acRate
            stats
            hints
            topic_tags: topicTags {
                name
                slug
            }
            similar: similarQuestionList {
                id: questionId
                difficulty
                title_slug: titleSlug
                title
                paid_only: isPaidOnly
            }
        }
    }
]]

queries.auth = [[
    query globalData {
        userStatus {
            id: userId
            name: username
            is_signed_in: isSignedIn
            is_premium: isPremium
            is_verified: isVerified
            session_id: activeSessionId
        }
    }
]]

---@return boolean
---@return string? # Error message
local function get_cookie()
    if cached_cookie then
        return true
    end

    local cookie = io_utils.read_file(config.cookie_file)
    if not cookie or cookie == '' then
        return false, 'Cookie not found. Check ' .. config.cookie_file .. '.'
    end

    local _, leetcode_session, _, csrftoken = unpack(vim.split(cookie, '\n'))

    if not leetcode_session or leetcode_session == '' or not csrftoken or csrftoken == '' then
        return false, 'Invalid cookie format. Check ' .. config.cookie_file .. '.'
    end

    cached_cookie = {
        leetcode_session = leetcode_session,
        csrftoken = csrftoken,
    }

    return true
end

local function get_title_slug(question_url)
    local title_slug = question_url:match('/problems/([a-zA-Z0-9%-_]+)/?')
    return title_slug
end

local function get_curl_command(query)
    local command = {
        'curl', '-s', '-w', '\nStatus: %{http_code}\n',
        '-X', 'POST', config.graphql_url,
        -- Headers
        '-H', 'User-Agent: ' .. config.user_agent,
        '-H', 'Referer: ' .. config.referer,
        '-H', 'Origin: ' .. config.origin,
        '-H', 'Content-Type: application/json',
        '-H', 'Accept: application/json',
        '-H', 'Host: leetcode.com',
    }
    if cached_cookie then
        vim.list_extend(command, {
            '-H', string.format('Cookie: LEETCODE_SESSION=%s; csrftoken=%s', cached_cookie.leetcode_session, cached_cookie.csrftoken),
            '-H', 'x-csrftoken: ' .. cached_cookie.csrftoken,
        })
    end
    -- Graphql queries
    vim.list_extend(command, {
        '-d', vim.json.encode(query),
    })
    return command
end

---@param res table The result decoded from the JSON data response
local function handle_http_error(res)
    if res.error then
        notify.error('[LeetCode] ' .. tostring(res.error))
    end

    if res.errors then
        local err_list = {}
        for _, e in ipairs(res.errors) do
            table.insert(err_list, e.message)
        end
        notify.error('[LeetCode] ' .. table.concat(err_list, '\n'))
    end
end

local function fulfill_query(query)
    local cmd = get_curl_command(query)
    local obj = vim.system(cmd, { text = true }):wait()
    if obj.code ~= 0 then
        notify.error({
            '[LeetCode] curl failed',
            obj.stderr,
            obj.stdout,
        })
        return
    end

    local body, status = obj.stdout:match('^(.*)\nStatus: (%d+)\n?$')
    if not body or not status then
        notify.error('[LeetCode] Failed to parse curl response.')
        return
    end

    local ok, res = pcall(vim.json.decode, body)
    if not ok then
        notify.error('[LeetCode] Failed to decode JSON response.')
        return
    end

    if status ~= '200' then
        notify.error('[LeetCode] HTTP error: ' .. status)
        handle_http_error(res)
        return
    end
    return res
end

local function html_to_markdown(html)
    if vim.fn.executable('pandoc') == 0 then
        notify.error('[LeetCode] pandoc is not executable.')
        return
    end

    local obj = vim.system({ 'pandoc', '-f', 'html', '-t', 'markdown' }, {
        stdin = html,
        text = true,
    }):wait()

    if obj.code ~= 0 then
        notify.error({
            '[LeetCode] pandoc failed to convert HTML to markdown',
            obj.stderr,
            obj.stdout,
        })
        return
    end

    return obj.stdout
        -- image style
        :gsub('!%[(.-)%]%((.-)%)%b{}', '!%[%1%](%2)')
        -- data-keyword
        :gsub('\n%[(.-)%]{keyword=.-}', ' %1')
        -- example-block
        :gsub(':::\n', '')
        :gsub(':::.-example%-block\n', '')
        -- example-io
        :gsub('%[([^\n]-)%]{%.example%-io}', '%1')
end

local function build_question_description(q, question_url)
    -- Build question info
    local info = {
        string.format('%s [Link](%s)', icons.emoji.link, question_url),
        icons.emoji.star .. ' ' .. q.difficulty,
        string.format('%s %s %s %s', icons.emoji.thumbsup, q.likes, icons.emoji.thumbsdown, q.dislikes),
    }

    local stats_ok, stats = pcall(vim.json.decode, q.stats)
    if stats_ok and stats.acRate and stats.totalSubmission then
        table.insert(info, string.format('%s of %s', stats.acRate, stats.totalSubmission))
    end

    if q.is_paid_only then
        table.insert(info, icons.emoji.lock)
    end

    -- Build question content
    local content = html_to_markdown(q.content)
    if not content then
        return
    end

    -- Build the topic tags
    local tags = {}
    for _, tag in ipairs(q.topic_tags) do
        local fmt_str = '[%s](https://leetcode.com/problem-list/%s)'
        table.insert(tags, fmt_str:format(tag.name, tag.slug))
    end

    -- Build the similar questions
    local similar = {}
    for _, s in ipairs(q.similar) do
        local fmt_str = '**[%s. %s](https://leetcode.com/problems/%s)** [%s]'
        table.insert(similar, fmt_str:format(s.id, s.title, s.title_slug, s.difficulty))
    end

    return {
        string.format('## %s. %s', q.id, q.title),
        '',
        string.format('**%s**', table.concat(info, ' | ')),
        '',
        content,
        '',
        '---',
        '',
        '**' .. icons.emoji.tag .. ' Topics**',
        '',
        table.concat(tags, ', '),
        '',
        '---',
        '',
        '**' .. icons.emoji.puzzle .. ' Similar Questions**',
        '',
        table.concat(similar, '  \n'),
    }
end

local function build_solution_snippet(q, lang)
    for _, code_snippet in ipairs(q.code_snippets) do
        if code_snippet.lang_slug == lang then
            local lines = vim.split(code_snippet.code, '\n', {
                plain = true,
                trimempty = true,
            })
            return table.concat(lines, '\n')
        end
    end
    return ''
end

local function get_user_status()
    local query = {
        query = queries.auth,
    }
    local res = fulfill_query(query)
    return res and res.data.userStatus or nil
end

local function get_question(title_slug)
    local query = {
        query = queries.question,
        variables = {
            titleSlug = title_slug,
        },
    }
    local res = fulfill_query(query)
    return res and res.data.question or nil
end

local function parse_args(args)
    if #args ~= 2 and #args ~= 3 then
        return nil, 'Expected 2 or 3 arguments: question URL, optional variant, and language'
    end

    local question_url, second, third = unpack(args)

    return {
        question_url = question_url,
        variant = third and second or '',
        lang = third or second,
    }
end

local function extract_question_url(url)
    return url:match('^(https://leetcode%.com/problems/[^/?#]+)')
end

---@param question_url string
---@param variant string "method-1" in method-1.cpp
---@param lang string "cpp" in method-1.cpp
local function run(question_url, variant, lang)
    question_url = extract_question_url(question_url)
    if not question_url then
        notify.error('[LeetCode] Invalid question URL. It should look like "https://leetcode.com/problems/two-sum/".')
        return
    end

    local cookie_ok, err = get_cookie()
    if not cookie_ok then
        notify.error('[LeetCode] ' .. err)
        return
    end

    -- Check cookie validation
    local user_status = get_user_status()
    if not user_status then
        return
    end
    if not user_status.is_signed_in then
        notify.error('[LeetCode] Cookie is expired. Update it in ' .. config.cookie_file .. '.')
        cached_cookie = nil
        return
    end

    local title_slug = get_title_slug(question_url)
    if not title_slug then
        notify.error('[LeetCode] Failed to parse question title slug')
        return
    end

    local q = get_question(title_slug)
    if not q then
        return
    end

    if q.is_paid_only and not user_status.is_premium then
        notify.warn('[LeetCode] Question is for premium users only')
        return
    end

    -- Create question directory
    local dirpath = string.format('%s/leetcode-%s/%s-%s', config.oj_dir, lang, q.id, q.title_slug)
    if vim.fn.isdirectory(dirpath) == 0 then
        local mkdir_ok = vim.fn.mkdir(dirpath, 'p')
        local dirpath_home = vim.fn.fnamemodify(dirpath, ':~')
        if mkdir_ok == 1 then
            notify.info('[LeetCode] Created directory: ' .. dirpath_home)
        else
            notify.error('[LeetCode] Failed to create directory: ' .. dirpath_home)
            return
        end
    end

    -- Build question description text
    local question_description = build_question_description(q, question_url)
    if not question_description then
        return
    end

    -- Create md file and write question description
    local md_name = string.format('%s-%s.md', q.id, q.title_slug)
    local md_path = dirpath .. '/' .. md_name
    if vim.uv.fs_stat(md_path) then
        vim.uv.fs_unlink(md_path)
    end
    local write_md_ok, write_md_err = pcall(io_utils.write_file, md_path, table.concat(question_description, '\n'))
    if not write_md_ok then
        notify.error(
            '[LeetCode] Failed to write md file: ' .. md_name .. '\n' .. tostring(write_md_err)
        )
        return
    end
    notify.info('[LeetCode] Create md file: ' .. md_name)

    -- Create a solution file and open it
    local basename = string.format('%s-%s', q.id, q.title_slug)
    if variant ~= '' then
        basename = basename .. '-' .. variant
    end
    local filename = string.format('%s.%s', basename, lang)
    local filepath = dirpath .. '/' .. filename
    if not vim.uv.fs_stat(filepath) then
        local snippet = build_solution_snippet(q, lang)
        if snippet == '' then
            notify.warn('[LeetCode] No code snippet found for language: ' .. lang)
        end
        local write_snippet_ok, write_snippet_err = pcall(io_utils.write_file, filepath, snippet)
        if not write_snippet_ok then
            notify.error(
                '[LeetCode] Failed to write solution file: '
                    .. filename
                    .. '\n'
                    .. tostring(write_snippet_err)
            )
            return
        end
        notify.info('[LeetCode] Created solution file: ' .. filename)
    else
        notify.warn('[LeetCode] Solution file already exists: ' .. filename)
    end
    vim.cmd.edit(vim.fn.fnameescape(filepath))
end

-- User command
-- E.g., :Leetcode https://leetcode.com/problems/two-sum/ method1 cpp
--                      |                                   |      |___ file extension
--                      |                                   |
--                      |____ question_url                  |___ solution variant
vim.api.nvim_create_user_command('LeetCode', function(args)
    local parsed, err = parse_args(args.fargs)
    if not parsed then
        notify.warn('[LeetCode] ' .. err)
        return
    end

    run(parsed.question_url, parsed.variant, parsed.lang)
end, { nargs = '+' })

local function get_url(obj)
    if obj.code ~= 0 then
        return
    end
    return extract_question_url(obj.stdout)
end

local function get_url_from_chrome()
    local obj = vim.system({
        'osascript',
        '-e',
        'tell application "Google Chrome" to get URL of active tab of front window',
    }, { text = true }):wait()
    return get_url(obj)
end

local function get_url_from_clipboard()
    local obj = vim.system({ 'pbpaste' }, { text = true }):wait()
    return get_url(obj)
end

vim.keymap.set('n', '<Leader>ol', function()
    local url = get_url_from_chrome() or get_url_from_clipboard()
    return url and ':LeetCode ' .. url .. ' ' or ':LeetCode '
end, { expr = true })
