local M = {}

-- Table to store terminal states
local terminals = {}

function M.open_term()
    -- Get the buffer number
    local bufnr = vim.fn.bufnr('%')

    -- If there's a saved terminal for this buffer, restore it
    if terminals[bufnr] then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, terminals[bufnr])
    else
        -- Otherwise, open a new terminal window
        vim.cmd('botright split | terminal')

        -- Make the window a popup
        vim.api.nvim_open_win(bufnr, true, {
            relative = 'editor',
            width = 80,
            height = 24,
            row = 2,
            col = 2,
            border = 'single'
        })

        -- Make the buffer a terminal
        vim.api.nvim_buf_set_option(bufnr, 'buftype', 'terminal')
    end
end

function M.save_term()
    local bufnr = vim.fn.bufnr('%')

    -- Save the terminal's current state
    terminals[bufnr] = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

return M
