--
-- Inspired by https://github.com/kawre/leetcode.nvim
--
-- Run command :LeetCode <question_url> <label>.<ext> that will first create a directory specific
-- this question and then genreate two files
-- (1). a md file containing question description
-- (2). a solution file with code snippet
--
-- For example, run :LeetCode https://leetcode.com/two-sum/description m1.js will create a directory
-- ~/oj/leetcode-js. Then it genreates two files under this directory
-- (1). 1-two-sum.md
-- (2). 1-two-sum-m1.js
--

local io_utils = require('rockyz.utils.io')
local system = require('rockyz.utils.system')
local notify = require('rockyz.utils.notify')
local icons = require('rockyz.icons')

local cookie_file = vim.env.XDG_CONFIG_HOME .. '/leetcode-cookie'
local oj_dir = vim.env.HOME .. '/oj'
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

local function get_cookie()
    if cached_cookie then
        return
    end
    local cookie = io_utils.read_file(cookie_file)
    local _, leetcode_session, _, csrftoken = unpack(vim.split(cookie, '\n'))
    if leetcode_session ~= '' and csrftoken ~= '' then
        cached_cookie = {
            leetcode_session = leetcode_session,
            csrftoken = csrftoken,
        }
    end
end

local function get_title_slug(question_url)
    local title_slug = question_url:match('/problems/([a-zA-Z0-9%-_]+)/?')
    return title_slug
end

local function get_curl_command(query)
    local command = {
        'curl', '-s', '-w', '\nStatus: %{http_code}\n',
        '-X', 'POST', 'https://leetcode.com/graphql/',
        -- Headers
        '-H', 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        '-H', 'Referer: https://leetcode.com',
        '-H', 'Origin: https://leetcode.com',
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
        notify.error('res.error')
    end
    if res.errors then
        local err_list = {}
        for _, e in ipairs(res.errors) do
            table.insert(err_list, e.message)
        end
        notify.error(table.concat(err_list, '\n'))
    end
end

local function fulfill_query(query)
    local cmd = get_curl_command(query)
    local obj = system.sync(cmd, { text = true })
    if obj.code ~= 0 then
        notify.error({
            '[LeetCode] curl failed',
            obj.stderr,
            obj.stdout,
        })
        return
    end
    local body, status = obj.stdout:match('^(.*)\nStatus: (%d+)\n?$')
    local res = vim.json.decode(body)
    if status ~= '200' then
        notify.error('[LeetCode] HTTP error: ' .. status)
        handle_http_error(res)
        return
    end
    return res
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

---@param question_url string
---@param method_id string "m1" in m1.cpp
---@param lang string "cpp" in m1.cpp
local function run(question_url, method_id, lang)
    get_cookie()
    if not cached_cookie then
        notify.error('[LeetCode] Cookie not found. Check ~/.config/leetcode-cookie.')
        return
    end

    -- Check cookie validation
    local user_status = get_user_status()
    if not user_status then
        return
    end
    if not user_status.is_signed_in then
        notify.error('[LeetCode] Cookie is expired. Update it in ~/.config/leetcode-cookie.')
        cached_cookie = nil
        return
    end
    -- notify.info('[LeetCode] Valid cookie is varified')

    question_url = question_url:match('^(https://leetcode%.com/problems/[^/]+)')
    local title_slug = get_title_slug(question_url)

    local q = get_question(title_slug)
    if not q then
        return
    end

    if q.is_paid_only and not user_status.is_premium then
        notify.warn('[LeetCode] Question is for premium users only')
        return
    end

    -- Create question directory
    local dirpath = string.format('%s/leetcode-%s/%s-%s', oj_dir, lang, q.id, q.title_slug)
    if vim.fn.isdirectory(dirpath) == 0 then
        local ok = vim.fn.mkdir(dirpath, 'p')
        local dirpath_home = vim.fn.fnamemodify(dirpath, ':~')
        if ok == 1 then
            notify.info('[LeetCode] Created directory: ' .. dirpath_home)
        else
            notify.error('[LeetCode] Failed to create directory: ' .. dirpath_home)
            return
        end
    end

    -- [1]. Question info

    local info = {
        string.format('%s [Link](%s)', icons.emoji.link, question_url),
        icons.emoji.star .. ' ' .. q.difficulty,
        string.format('%s %s %s %s', icons.emoji.thumbsup, q.likes, icons.emoji.thumbsdown, q.dislikes),
    }
    local stats = vim.json.decode(q.stats)
    table.insert(info, string.format('%s of %s', stats.acRate, stats.totalSubmission))
    if q.is_paid_only then
        table.insert(info, icons.emoji.lock)
    end

    -- [2]. Question content

    -- Convert HTML to markdown
    local html2md_obj = system.sync({
        'pandoc', '-f', 'html', '-t', 'markdown',
    }, { stdin = q.content })
    if html2md_obj.code ~= 0 then
        notify.error({
            '[LeetCode] pandoc failed',
            html2md_obj.stderr,
            html2md_obj.stdout,
        })
        return
    end
    -- Strip image style part
    local content = html2md_obj.stdout:gsub('!%[(.-)%]%((.-)%)%b{}', '!%[%1%](%2)')

    -- [3]. Topic tags

    local tags = {}
    for _, tag in ipairs(q.topic_tags) do
        local fmt_str = '[%s](https://leetcode.com/problem-list/%s)'
        table.insert(tags, fmt_str:format(tag.name, tag.slug))
    end

    -- [4]. Similar questions

    local similar = {}
    for _, s in ipairs(q.similar) do
        local fmt_str = '**[%s. %s](https://leetcode.com/problems/%s)** [%s]'
        table.insert(similar, fmt_str:format(s.id, s.title, s.title_slug, s.difficulty))
    end

    local question_description = {
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

    -- Create md file and write question description
    local md_name = string.format('%s-%s.md', q.id, q.title_slug)
    local md_path = dirpath .. '/' .. md_name
    local stat = vim.uv.fs_stat(md_path)
    if stat then
        vim.uv.fs_unlink(md_path)
    end
    local fd = vim.uv.fs_open(md_path, 'w', 438)
    if not fd then
        notify.error('[LeetCode] Failed to create md file: ' .. md_name)
        return
    end
    vim.uv.fs_close(fd)
    notify.info('[LeetCode] Created md file: ' .. md_name)

    io_utils.write_file(md_path, table.concat(question_description, '\n'))

    -- Create a solution file and open it
    local filename = string.format('%s-%s-%s.%s', q.id, q.title_slug, method_id, lang)
    local filepath = dirpath .. '/' .. filename
    stat = vim.uv.fs_stat(filepath)
    if not stat then
        fd = vim.uv.fs_open(filepath, 'w', 420)
        if not fd then
            notify.error('[LeetCode] Failed to create solution file: ' .. filename)
            return
        else
            notify.info('[LeetCode] Created solution file: ' .. filename)
            -- Write code snippet
            local code = {}
            for _, snippet in ipairs(q.code_snippets) do
                if snippet.lang_slug == lang then
                    local code_lines = vim.split(snippet.code, '\n', { plain = true, trimempty = true })
                    for _, line in ipairs(code_lines) do
                        table.insert(code, line)
                    end
                end
            end
            io_utils.write_file(filepath, table.concat(code, '\n'))
        end
    else
        notify.warn('[LeetCode] Solution file already exists: ' .. filename)
    end
    vim.cmd.edit(filepath)
end

vim.api.nvim_create_user_command('LeetCode', function(args)
    if #args.fargs ~= 2 then
        notify.warn('[LeetCode] Expected 2 arguments: question URL and filename')
        return
    end
    -- The first arg is the question url; the second arg is a filename like m1.cpp representing
    -- method 1, cpp solution.
    local question_url, filename = unpack(args.fargs)
    local method_id, ext = filename:match('^(.*)%.(.*)$')
    run(question_url, method_id, ext)
end, { nargs = '+' })
