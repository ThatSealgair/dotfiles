:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a
:set encoding=UTF-8
:set fileformat=unix

call plug#begin()
	Plug 'kyazdani42/nvim-web-devicons'
	Plug 'nvim-lualine/lualine.nvim'
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim' " TODO look at further extensions
	Plug 'jvgrootveld/telescope-zoxide'
	Plug 'http://github.com/tpope/vim-surround' " Surrounding TODO look at documentation
	Plug 'https://github.com/preservim/nerdtree' " NerdTree
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'nvim-neorg/neorg'
	" Plug 'liuchengxu/vim-which-key'
	" Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
	Plug 'https://github.com/ryanoasis/vim-devicons' " Developer Icons
	Plug 'https://github.com/tc50cal/vim-terminal' " Vim Terminal
	Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation
	Plug 'https://github.com/preservim/nerdcommenter'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	" Plug 'cdelledonne/vim-cmake'
	Plug 'https://www.github.com/neomake/neomake'
	Plug 'https://github.com/rust-analyzer/rust-analyzer'
	Plug 'lervag/vimtex'
	Plug 'sheerun/vim-polyglot'
   	Plug 'Konfekt/FastFold'
    Plug 'matze/vim-tex-fold'
	Plug 'dense-analysis/ale'
	Plug 'rust-lang/rust.vim'
	Plug 'rebelot/kanagawa.nvim'
	Plug 'jiangmiao/auto-pairs' " Auto-pairing
	Plug 'mfussenegger/nvim-dap' " Debugger Addaptor TODO look into this further
	Plug 'folke/which-key.nvim' " Displays all possible key binding of command being typed
	Plug 'mg979/vim-visual-multi', {'branch': 'master'} " TODO understand functionality better
	Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
	Plug 'rebelot/kanagawa.nvim'
call plug#end()

" ALE Settings
let g:ale_linters = {'c': ['clang', 'avr-gcc', 'arduino-cli'], 'cpp': ['clang', 'g++', 'avr-gcc-c++', 'arduino-cli'], 'go': ['gofmt', 'golint', 'go vet', 'golangserver'], 'latex': ['proselint', 'chktex', 'lacheck'], 'markdown': ['mdl'], 'python': ['flake8', 'pylint', 'pyls'], 'rust': ['analyzer'], 'vim': ['vint']}
let g:ale_fixers = { 'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'] }
let g:ale_disable_lsp = 1
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
" silent! helptags ALL
let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++1z'

let g:ale_c_clang_options = '-Wall -O2 -std=c99'
let g:ale_cpp_clang_options = '-Wall -O2 -std=c++1z'

let g:ale_c_cppcheck_options = ''
let g:ale_cpp_cppcheck_options = ''

" lualine
lua << END
	require('lualine').setup {
	  options = {
	    icons_enabled = true,
	    theme = 'kanagawa',
	    component_separators = { left = '', right = ''},
	    section_separators = { left = '', right = ''},
	    disabled_filetypes = {},
	    always_divide_middle = true,
	    globalstatus = false,
	  },
	  sections = {
	    lualine_a = {'mode'},
	    lualine_b = {'branch', 'diff', 'diagnostics'},
	    lualine_c = {'filename'},
	    lualine_x = {'encoding', 'fileformat', 'filetype'},
	    lualine_y = {'progress'},
	    lualine_z = {'location'}
	  },
	  inactive_sections = {
	    lualine_a = {},
	    lualine_b = {},
	    lualine_c = {'filename'},
	    lualine_x = {'location'},
	    lualine_y = {},
	    lualine_z = {}
	  },
	  tabline = {},
	  extensions = {}
	}

	require('nvim-treesitter.configs').setup {
		ensure_installed = { "norg", --[[ other parsers you would wish to have ]] },
		highlight = { -- Be sure to enable highlights if you haven't!
			enable = true,
		}
	}

	require('neorg').setup {
		load = {
			["core.defaults"] = {}
		}
	}

	require('telescope').setup{
		defaults = {
			-- Default configuration for telescope goes here:
			-- config_key = value,
			mappings = {
				i = {
				-- map actions.which_key to <C-h> (default: <C-/>)
				-- actions.which_key shows the mappings for your picker,
				-- e.g. git_{create, delete, ...}_branch for the git_branches picker
				["<C-h>"] = "which_key"
				}
			}
		},
		pickers = {
		-- Default configuration for builtin pickers goes here:
		-- picker_name = {
		--   picker_config_key = value,
		--   ...
		-- }
		-- Now the picker_config_key will be applied every time you call this
		-- builtin picker
		},
		extensions = {
		-- Your extension configuration goes here:
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- please take a look at the readme of the extension you want to configure
		}
	}

	--require'telescope'.load_extension('zoxide')

END
set termguicolors

" colorscheme tokyonight
colorscheme kanagawa

"Commands for vimtex"
filetype plugin indent on
syntax enable
let g:tex_flavour = 'latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_method = 'latexmk'
let maplocalleader = ","
augroup vimtex_config
  autocmd User VimtexEventInitPost VimtexCompile
augroup END

