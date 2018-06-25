# Key bindings
# ------------
if [[ $- != *i* ]]; then
	return
fi

function __results_to_args
{
    local prefix="$1"

    while read item; do
        local full_item="${prefix}${item}"
        echo -n "${(q)full_item} "
    done
}

function __fzfcmd
{
	echo "fzf ${FZF_BEW_LAYOUT} ${FZF_BEW_KEYBINDINGS}"
}

function __get_prefix
{
    # local completion_prefix="${LBUFFER/* /}"

    ### Prefix (part of arg before cursor (represented as: |))
    #
    # 1. can be empty
    #    > | <
    #
    #    => _prefix=''
    #
    # 2. can be in a shell argument
    #    > vim foo|bar <
    #
    #    => _prefix='foo'
    #
    # 3. cursor can be on whitespace
    #    > vim foo| bar <
    #
    #    => _prefix='foo'
    #
    # 4. cursor can be in last whitespace
    #    > vim foo  |       <
    #
    #    => _prefix=''
    #
    # 5. cursor can be at eol
    #    > vim foo  | <
    #
    #    => _prefix=''
    #
    # 6. cursor can be at eol and after shell arg
    #    > vim foo| <
    #
    #    => _prefix='foo'

    local reply REPLY REPLY2
    autoload -Uz split-shell-arguments
    split-shell-arguments
    local shell_args=(${reply[@]}) arg_no=$REPLY cursor=$REPLY2

    # return vars
    typeset -g _prefix

    if (( arg_no == ${#shell_args} )); then
        # cursor is in last whitespace area or at eol

        # need to check the cursor is next to

    elif (( arg_no % 2 == 1 )); then
        # cursor on whitespace
        ;
    else
        # cursor on shell argument
        local shell_arg=${reply[$REPLY]}
        if (( REPLY2 == 1 )); then
            # cursor at beginning of arg
            _base_dir=''
            _query=''
        else
        fi

    fi
}

function __base_dir_from_prefix
{
    # $ mkdir -p dir; touch dir/file{1,2}
    #
    # TODO: redo this overview
    ### Prefix (part of arg before cursor (represented as: |))
    #
    # 1. can be empty
    #    > vim |
    #
    # 2. can be a dir (with(out) trailing /)
    #    > vim dir|
    #    > vim dir/|
    #
    # 3. can be partial path
    #    > vim dir/fi|
    #
    #    => base_dir='dir'
    #    => query='fi'
}

function zwidget::fzf::find_file
{
	local completion_prefix="${LBUFFER/* /}"
	local lbuffer_without_completion_prefix="${LBUFFER%${completion_prefix}}"

    local base_dir=${completion_prefix:-./}

    local finder_cmd=(fd --type f --type l)
    local fzf_cmd=($(__fzfcmd) --multi --prompt "${~base_dir}")
	local cpl=$(cd "$base_dir"; "${finder_cmd[@]}" | "${fzf_cmd[@]}" | __results_to_args "$base_dir")
    local selected_completions=$cpl

	if [ -n "$selected_completions" ]; then
		LBUFFER="${lbuffer_without_completion_prefix}${selected_completions}"
	fi
	zle reset-prompt
}
zle -N zwidget::fzf::find_file

function zwidget::fzf::find_directory
{
	local completion_prefix="${LBUFFER/* /}"
	local lbuffer_without_completion_prefix="${LBUFFER%$completion_prefix}"

    local base_dir=${completion_prefix:-./}

    local finder_cmd=(fd --type d)
    local fzf_cmd=($(__fzfcmd) --multi --prompt "${~base_dir}")
	local cpl=$(cd "$base_dir"; "${finder_cmd[@]}" | "${fzf_cmd[@]}" | __results_to_args "$base_dir")
    local selected_completions=$cpl

	if [ -n "$selected_completions" ]; then
		LBUFFER="${lbuffer_without_completion_prefix}${selected_completions}"
	fi
	zle reset-prompt
}
zle -N zwidget::fzf::find_directory


FZF_HISTORY_OPTIONS=(--no-multi -n2..,.. --tiebreak=index)

function zwidget::fzf::history
{
    # -l  | list the commands
    # -r  | show in reverse order (=> most recent first)
    # 1   | start at command n° 1 (the oldest still in history)
    local history_cmd=(fc -lr 1)

    local fzf_cmd=($(__fzfcmd) $FZF_HISTORY_OPTIONS --query "${LBUFFER//$/\\$}")
	local selected=( $( "${history_cmd[@]}" | "${fzf_cmd[@]}" ) )
	if [ -n "$selected" ]; then
		local history_index=$selected[1]
		if [ -n "$history_index" ]; then
			zle vi-fetch-history -n $history_index
		fi
	fi
	zle reset-prompt
}
zle -N zwidget::fzf::history

# --nth 2..         | ignore first field (the popularity of the dir) when matching
FZF_Z_OPTIONS=(--tac --tiebreak=index --nth 2..)

function zwidget::fzf::z
{
    local last_pwd=$PWD

    local fzf_cmd=($(__fzfcmd) $FZF_Z_OPTIONS --prompt 'Fuzzy jump to: ')
    local selected=( $( z | "${fzf_cmd[@]}" ) )
    if [ -n "$selected" ]; then
        local directory=$selected[2]
        if [ -n "$directory" ]; then
            cd $directory
            HOOK_LIKE_TOPLEVEL=1 hooks-run-hook chpwd_hook
        fi
    fi
    zle reset-prompt

    if [ $last_pwd != $PWD ]; then
        zle -M "cd'ed to '$PWD'"
    fi
}
zle -N zwidget::fzf::z
