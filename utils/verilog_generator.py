import os
import subprocess
import inspect


class VerilogGenerator(object):
    def __init__(self, dirname: str=os.path.join(os.curdir, '..', 'code_gen'), filename: str='module'):
        super(VerilogGenerator, self).__init__()

        self.dirname = dirname
        self.filename = filename
        self.vfilename = filename + '.v'
        self.ofilename = filename + '.vvp'
        self.clog_filename = filename + '_compile.log'

        self.content = list()
        self.linenum = list()

        self.elinenum = list()
        self.enames = dict()

        os.makedirs(dirname, exist_ok=True)

    def reset(self):
        self.content = list()
        self.linenum = list()

    def register_line(self, code: str) -> None:
        lnum = inspect.stack()[-1].lineno

        for lidx, line in enumerate(code.split('\n')):
            self.content.append(line)
            self.linenum.append(lnum + lidx)

    def compile(self, remove_tmpfile=True):
        with open(os.path.join(self.dirname, self.vfilename), 'wt') as file:
            file.write('\n'.join(self.content))

        with open(os.path.join(self.dirname, self.clog_filename), 'wt') as file:
            compile_result = subprocess.run(
                f"iverilog -o \"{os.path.join(self.dirname, self.ofilename)}\" {os.path.join(self.dirname, self.vfilename)}", stdout=file,
                stderr=file)

        self.elinenum = []
        self.enames = {}

        with open(os.path.join(self.dirname, self.clog_filename), 'rt') as file:
            for eline in file.readlines():
                eparsed = eline.split(':')

                if len(eparsed) < 3:
                    continue

                efile = eparsed[0]
                eidx = int(eparsed[1]) - 1
                ename = ':'.join(eparsed[2:]).strip()

                if self.linenum[eidx] not in self.elinenum:
                    self.elinenum.append(self.linenum[eidx])

                if self.linenum[eidx] not in self.enames.keys():
                    self.enames[self.linenum[eidx]] = []

                if ename not in self.enames[self.linenum[eidx]]:
                    self.enames[self.linenum[eidx]].append(f"{ename}  {efile}")

        if remove_tmpfile:
            if os.path.isfile(os.path.join(self.dirname, self.ofilename)):
                os.remove(os.path.join(self.dirname, self.ofilename))
            if os.path.isfile(os.path.join(self.dirname, self.clog_filename)):
                os.remove(os.path.join(self.dirname, self.clog_filename))

    def print_result(self):
        print(f"Compile Configs")
        print(f"- dirname:  {self.dirname if self.dirname != os.curdir else '(current directory)'}")
        print(f"- filename: {self.filename}\n")

        for el in self.elinenum:
            enn = '\n'.join(f'  [{ei + 1}] {en}' for ei, en in enumerate(self.enames[el][:min(len(self.enames[el]), 10)]))
            print(f"ln {el:4d}\n{enn}" + ('' if len(self.enames[el]) <= 10 else f'\n  ({len(self.enames[el])-10} more errors occurred)'), end='\n')