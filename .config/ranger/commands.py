# This file contains the user defined commands.
# The example of this file can be found here: https://github.com/ranger/ranger/blob/master/ranger/config/commands_sample.py
# The complete built-in ranger commands definitions can be found here (as a reference): https://github.com/ranger/ranger/blob/master/ranger/config/commands.py

from ranger.api.commands import Command

class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        from os.path import join, expanduser, lexists
        from os import makedirs
        import re

        dirname = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if not lexists(dirname):
            makedirs(dirname)

            match = re.search('^/|^~[^/]*/', dirname)
            if match:
                self.fm.cd(match.group(0))
                dirname = dirname[match.end(0):]

            for m in re.finditer('[^/]+', dirname):
                s = m.group(0)
                if s == '..' or (s.startswith('.') and not self.fm.settings['show_hidden']):
                    self.fm.cd(s)
                else:
                    ## We force ranger to load content before calling `scout`.
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console('scout -ae ^{}$'.format(s))
        else:
            self.fm.notify("file/directory exists!", bad=True)

class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """
    def execute(self):
        import subprocess
        import os.path
        if self.quantifier:
            # match only directories
            command="fd --type d --hidden --follow --exclude .git --exclude .DS_Store | fzf +m"
        else:
            # match files and directories
            command="fd --hidden --follow --exclude .git --exclude .DS_Store | fzf +m"
        fzf = self.fm.execute_command(command, universal_newlines=True, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)

class z(Command):
    """
    :z <dir1> <dir2> ... <dirn>

    Uses .zlua file to set the current directory.

    See: https://github.com/ask1234560/ranger-zjumper/blob/master/zjumper_ranger.py
    """
    def execute(self):
        from os import getenv
        import re

        # location of .zlua file
        z_loc = getenv("_ZL_DATA") or getenv("HOME")+"/.zlua"
        with open(z_loc,"r") as fobj:
            flists = fobj.readlines()

        # user given directory
        req = re.compile(".*".join(self.args[1:]),re.IGNORECASE)
        directories = []
        for i in flists:
            if req.search(i):
                directories.append(i.split("|")[0])

        try:
            #  smallest(length) directory will be the directory required
            self.fm.execute_console("cd " + min(directories,key=lambda x: len(x)))
        except Exception as e:
            raise Exception("Directory not found")

from collections import deque
fd_deq = deque()
class fd_search(Command):
    """
    :fd_search [-d<depth>] <query>

    <query> is a regex

    Executes "fd -d<depth> <query>" in the current directory and focuses the
    first match (can be a dir or a file). <depth> defaults to 1, i.e. only
    the contents of the current directory.
    """

    def execute(self):
        import subprocess
        import os
        from ranger.ext.get_executables import get_executables

        if not 'fd' in get_executables():
            self.fm.notify("Couldn't find fd on the PATH.", bad=True)
            return
        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = self.rest(2)
            else:
                depth = '-d1'
                target = self.rest(1)
        else:
            self.fm.notify(":fd_search needs a query.", bad=True)
            return

        # For convenience, change which dict is used as result_sep to change
        # fd's behavior from splitting results by \0, which allows for newlines
        # in your filenames to splitting results by \n, which allows for \0 in
        # filenames.
        null_sep = {'arg': '-0', 'split': '\0'}
        nl_sep = {'arg': '', 'split': '\n'}
        result_sep = null_sep

        process = subprocess.Popen(['fd', result_sep['arg'], depth, target],
                    universal_newlines=True, stdout=subprocess.PIPE)
        (search_results, _err) = process.communicate()
        global fd_deq
        fd_deq = deque((self.fm.thisdir.path + os.sep + rel for rel in
            sorted(search_results.split(result_sep['split']), key=str.lower)
            if rel != ''))
        if len(fd_deq) > 0:
            self.fm.select_file(fd_deq[0])

class fd_next(Command):
    """
    :fd_next

    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_deq) > 1:
            fd_deq.rotate(-1) # rotate left
            self.fm.select_file(fd_deq[0])
        elif len(fd_deq) == 1:
            self.fm.select_file(fd_deq[0])

class fd_prev(Command):
    """
    :fd_prev

    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_deq) > 1:
            fd_deq.rotate(1) # rotate right
            self.fm.select_file(fd_deq[0])
        elif len(fd_deq) == 1:
            self.fm.select_file(fd_deq[0])

class show_files_in_finder(Command):
    """
    :show_files_in_finder

    Present selected files in finder
    """

    def execute(self):
        import subprocess
        files = ",".join(['"{0}" as POSIX file'.format(file.path) for file in self.fm.thistab.get_selection()])
        reveal_script = "tell application \"Finder\" to reveal {{{0}}}".format(files)
        activate_script = "tell application \"Finder\" to set frontmost to true"
        script = "osascript -e '{0}' -e '{1}'".format(reveal_script, activate_script)
        self.fm.notify(script)
        subprocess.check_output(["osascript", "-e", reveal_script, "-e", activate_script])
