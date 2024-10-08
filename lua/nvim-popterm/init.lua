local M = {}

M.default_opts = {}

M.opts = {}

-- example function
function M.setup(opts)
    opts = opts or {}
    M.opts = vim.tbl_extend('force', M.default_opts, opts)
    vim.api.nvim_command 'command! ToggleTerm lua require("nvim-popterm").toggle_term()'
    -- vim.cmd('autocmd TermLeave * lua require("nvim-popterm").save_term()')
    -- vim.cmd('autocmd TermLeave * lua require("nvim-popterm").close_term()')
end

-- Store the window ID of the terminal
local win_id = nil
local bufnr = nil
-- Get the dimensions of the screen
local width = vim.api.nvim_get_option 'columns'
local height = vim.api.nvim_get_option 'lines'

-- Set the dimensions of the window
local win_width = width - 20
local win_height = height - 10

-- Calculate the position of the window to center it
local row = math.ceil((height - win_height) / 2 - 1)
local col = math.ceil((width - win_width) / 2 - 1)

function M.toggle_term()
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        -- If the window is currently visible, hide it
        if vim.fn.pumvisible() == 0 and vim.fn.winnr '$' > 1 then
            vim.api.nvim_win_hide(win_id)
            if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end
        else
            -- If the window is currently hidden, make it visible
            -- and use a throwaway buffer
            if not bufnr then
                bufnr = vim.api.nvim_create_buf(false, true)
            end
            vim.api.nvim_win_set_buf(win_id, bufnr)
        end
    else
        -- Otherwise, create a new terminal buffer
        -- check if bufnr is valid
        if not bufnr then
            bufnr = vim.api.nvim_create_buf(false, true)
        else
            if not vim.api.nvim_buf_is_valid(bufnr) then
                bufnr = vim.api.nvim_create_buf(false, true)
            end
        end

        local cwd = vim.fn.getcwd()
        local dir_name = vim.fn.fnamemodify(cwd, ':t')
        local parent_dir_name = vim.fn.fnamemodify(vim.fn.fnamemodify(cwd, ':h'), ':t')

        -- create session name by concatenating parent directory name and current directory name
        local session_name = parent_dir_name .. '_' .. dir_name

        -- Start a new tmux session or attach to an existing one
        vim.api.nvim_buf_call(bufnr, function()
            vim.cmd('terminal tmux new-session -A -s ' .. session_name)
            vim.cmd 'normal a'
        end)

        -- Create a new floating window for the terminal
        win_id = vim.api.nvim_open_win(bufnr, true, {
            relative = 'editor',
            width = win_width,
            height = win_height,
            row = row,
            col = col,
            border = 'rounded',
            style = 'minimal',
        })
    end
end

return M
