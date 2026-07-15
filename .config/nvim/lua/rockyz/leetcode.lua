--
-- Inspired by https://github.com/kawre/leetcode.nvim
--
-- Run command :LeetCode <url> [variant] <lang>. It first creates a directory for the question and
-- then generates two files:
-- (1). a md file containing question description
-- (2). a solution file with code snippet
--
-- The question description is always refreshed from LeetCode so the local markdown stays
-- synchronized with the latest version.
--
-- For example, run :LeetCode https://leetcode.com/problems/two-sum/description/ method-1 js
--
--   - First, it creates a directory ~/oj/leetcode-js to store all JavaScript solutions if it does
--     not exist yet
--   - Next, it creates a subdirectory 1-two-sum for the solutions of this specific question
--   - Last, it generates two files under this directory:
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
    cookie_file = vim.fs.joinpath(vim.env.HOME, '.config/leetcode-cookie'),
    oj_dir = vim.fs.joinpath(vim.env.HOME, 'oj'),
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

    local cookie_lines = vim.split(cookie, '\n', { plain = true })
    local _, leetcode_session, _, csrftoken = unpack(cookie_lines)

    leetcode_session = leetcode_session and vim.trim(leetcode_session)
    csrftoken = csrftoken and vim.trim(csrftoken)

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
        'curl', '-sS',
        '--connect-timeout', '10',
        '--max-time', '30',
        '-w', '\nStatus: %{http_code}\n',
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

---@param status string
---@param res table The result decoded from the JSON data response
---@return boolean # Whether the response contains an error
local function handle_query_errors(status, res)
    local messages = {}

    if status ~= '200' then
        table.insert(messages, 'HTTP error: ' .. status)
    end

    if res.error ~= nil then
        local message = type(res.error) == 'string' and res.error or vim.inspect(res.error)
        table.insert(messages, message)
    end

    if type(res.errors) == 'table' then
        for _, err in ipairs(res.errors) do
            local message = type(err) == 'table' and err.message or nil
            table.insert(messages, message and tostring(message) or vim.inspect(err))
        end
    end

    if #messages == 0 then
        return false
    end

    notify.error('[LeetCode] ' .. table.concat(messages, '\n'))
    return true
end

local function fulfill_query(query)
    local command = get_curl_command(query)
    local obj = vim.system(command, { text = true }):wait()
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
    if not ok or type(res) ~= 'table' then
        notify.error('[LeetCode] Expected a JSON object in HTTP ' .. status .. ' response')
        return
    end

    if handle_query_errors(status, res) then
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

---@param question table The question returned by the LeetCode GraphQL API
---@param question_url string
---@return string[]?
local function build_question_description(question, question_url)
    -- Build question info
    local question_info = {
        string.format('%s [Link](%s)', icons.emoji.link, question_url),
        icons.emoji.star .. ' ' .. question.difficulty,
        string.format('%s %s %s %s', icons.emoji.thumbsup, question.likes, icons.emoji.thumbsdown, question.dislikes),
    }

    local stats_ok, stats = pcall(vim.json.decode, question.stats)
    if stats_ok and stats.acRate and stats.totalSubmission then
        table.insert(question_info, string.format('%s of %s', stats.acRate, stats.totalSubmission))
    end

    if question.is_paid_only then
        table.insert(question_info, icons.emoji.lock)
    end

    -- Build question content
    local content = html_to_markdown(question.content)
    if not content then
        return
    end

    -- Build the topic tags
    local tags = {}
    for _, tag in ipairs(question.topic_tags) do
        local format_string = '[%s](https://leetcode.com/problem-list/%s)'
        table.insert(tags, format_string:format(tag.name, tag.slug))
    end

    -- Build the similar questions
    local similar_questions = {}
    for _, similar_question in ipairs(question.similar) do
        local format_string = '**[%s. %s](https://leetcode.com/problems/%s)** [%s]'
        table.insert(
            similar_questions,
            format_string:format(
                similar_question.id,
                similar_question.title,
                similar_question.title_slug,
                similar_question.difficulty
            )
        )
    end

    return {
        string.format('## %s. %s', question.id, question.title),
        '',
        string.format('**%s**', table.concat(question_info, ' | ')),
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
        table.concat(similar_questions, '  \n'),
    }
end

---@param question table The question returned by LeetCode GraphQL API
---@param lang string
---@return string
local function build_solution_snippet(question, lang)
    for _, code_snippet in ipairs(question.code_snippets) do
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
    return res and res.data and res.data.userStatus or nil
end

local function get_question(title_slug)
    local query = {
        query = queries.question,
        variables = {
            titleSlug = title_slug,
        },
    }
    local res = fulfill_query(query)
    return res and res.data and res.data.question or nil
end

---@param value string
---@return boolean
local function is_safe_file_component(value)
    return value:match('^[%w][%w%+._-]*$') ~= nil
end

local function parse_args(args)
    if #args ~= 2 and #args ~= 3 then
        return nil, 'Expected 2 or 3 arguments: question URL, optional variant, and language'
    end

    local question_url, second, third = unpack(args)
    local variant = third and second or ''
    local lang = third or second

    if not is_safe_file_component(lang) then
        return nil, 'Language can only contain letters, digits, "+", ".", "_", and "-"'
    end

    if variant ~= '' and not is_safe_file_component(variant) then
        return nil, 'Variant can only contain letters, digits, "+", ".", "_", and "-"'
    end

    return {
        question_url = question_url,
        variant = variant,
        lang = lang,
    }
end

local function extract_question_url(url)
    return url:match('^(https://leetcode%.com/problems/[^/?#]+)')
end

---@param question_url string
---@param variant string "method-1" in method-1.cpp
---@param lang string "cpp" in method-1.cpp
local function run(question_url, variant, lang)
    -- Validate input
    question_url = extract_question_url(question_url)
    if not question_url then
        notify.error('[LeetCode] Invalid question URL. It should look like "https://leetcode.com/problems/two-sum/".')
        return
    end

    -- Ensure authentication
    local cookie_ok, err = get_cookie()
    if not cookie_ok then
        notify.error('[LeetCode] ' .. err)
        return
    end

    -- Check cookie validation
    local user_status = get_user_status()
    if not user_status then
        cached_cookie = nil
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

    -- Fetch question
    local question = get_question(title_slug)
    if not question then
        return
    end

    if question.is_paid_only and not user_status.is_premium then
        notify.warn('[LeetCode] Question is for premium users only')
        return
    end

    -- Build question description text
    local question_description = build_question_description(question, question_url)
    if not question_description then
        return
    end

    -- Create the question directory
    local question_dir = vim.fs.joinpath(
        config.oj_dir,
        'leetcode-' .. lang,
        string.format('%s-%s', question.id, question.title_slug)
    )

    if vim.fn.isdirectory(question_dir) == 0 then
        local mkdir_ok = vim.fn.mkdir(question_dir, 'p')
        local question_dir_home = vim.fn.fnamemodify(question_dir, ':~')
        if mkdir_ok == 1 then
            notify.info('[LeetCode] Created directory: ' .. question_dir_home)
        else
            notify.error('[LeetCode] Failed to create directory: ' .. question_dir_home)
            return
        end
    end

    -- Write the refreshed question description
    local md_name = string.format('%s-%s.md', question.id, question.title_slug)
    local md_path = vim.fs.joinpath(question_dir, md_name)

    local write_md_ok, write_md_err = pcall(io_utils.write_file, md_path, table.concat(question_description, '\n'))
    if not write_md_ok then
        notify.error(
            '[LeetCode] Failed to write md file: ' .. md_name .. '\n' .. tostring(write_md_err)
        )
        return
    end

    notify.info('[LeetCode] Wrote markdown file: ' .. md_name)

    -- Create a solution file and open it
    local basename = string.format('%s-%s', question.id, question.title_slug)
    if variant ~= '' then
        basename = basename .. '-' .. variant
    end
    local filename = string.format('%s.%s', basename, lang)
    local file_path = vim.fs.joinpath(question_dir, filename)
    if not vim.uv.fs_stat(file_path) then
        local snippet = build_solution_snippet(question, lang)
        if snippet == '' then
            notify.warn('[LeetCode] No code snippet found for language: ' .. lang)
        end
        local write_snippet_ok, write_snippet_err = pcall(io_utils.write_file, file_path, snippet)
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
    vim.cmd.edit(vim.fn.fnameescape(file_path))
end

-- User command
-- E.g., :LeetCode https://leetcode.com/problems/two-sum/ method1 cpp
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
