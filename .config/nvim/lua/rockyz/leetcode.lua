--
-- Inspired by https://github.com/kawre/leetcode.nvim
--
-- Run command :LeetCode <question_url> <language> to generate a file that contains the problem
-- description and the code snippet.
--
-- For example, run :LeetCode https://leetcode.com/two-sum/description javascript will create a file
-- ~/.config/oj/leetcode-javascript/two-sum.js.
--

local io_utils = require('rockyz.utils.io_utils')
local system = require('rockyz.utils.system_utils')
local notify = require('rockyz.utils.notify_utils')
local icons = require('rockyz.icons')

-- The file storing leetcode.com cookie
local cookie_file = vim.env.XDG_CONFIG_HOME .. '/leetcode-cookie'

-- Each solution is saved in a file ~/oj/leetcode-<lang>/<question_id>-<title>-<MMDDYYYY>.<lang>
local solution_dir = vim.env.HOME .. '/oj'

local cached_cookie

local line_length = 100

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

-- Map from language to file extension
-- Language should be given with LeetCode command
local lang_to_ext = {
    c = 'c',
    cpp = 'cpp',
    csharp = 'cs',
    golang = 'go',
    java = 'java',
    javascript = 'js',
    python = 'py',
    python3 = 'py',
    rust = 'rust',
    typescript = 'ts',
}

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

---@param q_id string Question id
---@param q_title string Question title
---@param lang string language I want to write in
---@return string|nil # Return the path of newly created file
local function create_file(q_id, q_title, lang)
    local ext = lang_to_ext[lang]
    local date = os.date('%m%d%y')
    local path = string.format('%s/leetcode-%s', solution_dir, lang)
    local name = string.format('%s-%s-%s.%s', q_id, q_title, date, ext)
    local filepath = path .. '/' .. name

    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, 'p')
    end

    local filepath_home = vim.fn.fnamemodify(filepath, ':~')
    local stat = vim.uv.fs_stat(filepath)
    if not stat then
        local fd = vim.uv.fs_open(filepath, "w", 420)
        if fd then
            vim.uv.fs_close(fd)
            notify.info('[LeetCode] Created file: ' .. filepath_home)
            return filepath
        else
            notify.error('[LeetCode] Failed to create file: ' .. filepath_home)
        end
    else
        notify.warn('[LeetCode] File already exists: ' .. filepath_home)
    end
end

---@param res table result decoded from the response JSON data
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

local function run(question_url, lang)
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

    local content = q.content

    -- Convert HTML to plain text
    -- Keep image url, replace non-breaking spaces with regular spaces
    content = content
        :gsub('<img%s+[^>]*src="([^"]+)"[^>]*>', '[Image: %1]')
        :gsub('&nbsp;', ' ')
        :gsub('\u{00A0}', ' ')
    local html2text_obj = system.sync({
        'pandoc', '-f', 'html', '-t', 'plain',
    }, { stdin = content })
    if html2text_obj.code ~= 0 then
        notify.error({
            '[LeetCode] pandoc failed',
            html2text_obj.stderr,
            html2text_obj.stdout,
        })
        return
    end

    -- Create the file and open it
    local newfile = create_file(q.id, q.title_slug, lang)
    if not newfile then
        return
    end
    vim.cmd.edit(newfile)

    local lines = {}
    local commentstring = vim.bo.commentstring
    local comment_chars = commentstring:match('^(.-)%%s') or '# '

    local function center_str(str)
        local indent = math.max(0, math.floor((line_length - vim.fn.strdisplaywidth(str)) / 2))
        return comment_chars .. (' '):rep(indent) .. str
    end

    -- Put questiont title and center it
    table.insert(lines, center_str(q.id .. '. ' .. q.title))
    table.insert(lines, '')

    -- Put question url and center it
    table.insert(lines, center_str(question_url))

    -- Put questin info and center it
    local info = {
        q.difficulty,
        string.format('%s %s  %s %s ', q.likes, icons.misc.thumbsup, q.dislikes, icons.misc.thumbsdown),
    }
    local stats = vim.json.decode(q.stats)
    table.insert(info, string.format('%s of %s', stats.acRate, stats.totalSubmission))
    if q.is_paid_only then
        table.insert(info, icons.misc.lock .. ' ')
    end
    table.insert(lines, center_str(table.concat(info, ' | ')))

    table.insert(lines, '')

    -- Put question content
    for line in html2text_obj.stdout:gmatch('([^\n]*)\n?') do
        local commented = comment_chars .. line
        table.insert(lines, commented)
    end

    table.insert(lines, '')

    -- Put code snippet
    for _, snippet in ipairs(q.code_snippets) do
        if snippet.lang_slug == lang then
            local code_lines = vim.split(snippet.code, '\n', { plain = true, trimempty = true })
            for _, line in ipairs(code_lines) do
                table.insert(lines, line)
            end
        end
    end

    -- Clean: trim trailing whitespaces
    local cleaned = {}
    for _, line in ipairs(lines) do
        local trimmed = line:gsub('%s+$', '')
        table.insert(cleaned, trimmed)
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, cleaned)
end

vim.api.nvim_create_user_command('LeetCode', function(args)
    if #args.fargs ~= 2 then
        notify.warn('[LeetCode] Expected 2 arguments: question URL and language')
        return
    end
    local question_url, lang = unpack(args.fargs)
    run(question_url, lang)
end, { nargs = '+' })
