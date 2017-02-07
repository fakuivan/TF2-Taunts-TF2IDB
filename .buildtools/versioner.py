import subprocess
import os
import argparse

class Versioner:
    class FolderChanger:
        def __init__(self, folder):
            self.old = os.getcwd()
            self.new = folder

        def __enter__(self):
            if self.new:
                os.chdir(self.new)

        def __exit__(self, type, value, traceback):
            os.chdir(self.old)
    
    def __init__(self, git_path, tag_if_none):
        self.git_path = os.path.realpath(git_path)
        self.tag_if_none = tag_if_none

    def run_and_return(self, argv):
        # Python 2.6 doesn't have check_output.
        if hasattr(subprocess, 'check_output'):
            text = subprocess.check_output(argv)
            if str != bytes:
                text = str(text, 'utf-8')
        else:
            p = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, ignored = p.communicate()
            rval = p.poll()
            if rval:
                raise subprocess.CalledProcessError(rval, argv)
            text = output.decode('utf8')
        return text.strip()
        
    def get_version_from_git(self):
        tag = None
        commit_number = None
        try:
            from git import Repo 
            repo = Repo(self.git_path)
            if len(repo.tags) < 1:
                tag = self.tag_if_none
            else:
                tag = repo.tags[-1]
            commit_number = sum(1 for _ in repo.iter_commits())
        except ImportError:
            with Versioner.FolderChanger(self.git_path):
                commit_number = self.run_and_return(['git', 'rev-list', '--count', 'HEAD'])
                try:
                    tag = self.run_and_return(['git', 'describe', '--tags', 'HEAD'])
                except subprocess.CalledProcessError as e:
                    if e.returncode == 128:
                        tag = self.tag_if_none
                    else:
                        raise e
        return tag, commit_number

def main():
    parser = argparse.ArgumentParser(description='Add autoversioning to your SourceMod script.')
    parser.add_argument('git_dir', metavar='G', type=str, help='The root git directory of your project')
    parser.add_argument('include_dir', metavar='I', type=str, help='The path where to drop the include')
    parser.add_argument('tag_if_none', metavar='T', type=str, help='Use this tag if autoversioning fails')
    args = parser.parse_args()
    git_dir = os.path.abspath(args.git_dir)
    include_dir = os.path.abspath(args.include_dir)
    tag_if_none = args.tag_if_none
    template = """#if defined _autoversioning_included
 #endinput
#endif
#define _autoversioning_included
#define AUTOVERSIONING_TAG "{}"
#define AUTOVERSIONING_COMMIT "{}" """
    tag, commit_number = Versioner(git_dir, tag_if_none).get_version_from_git()
    file_content = template.format(tag, commit_number)
    with open(os.path.join(include_dir, "autoversioning.inc"), "w") as file:
        file.write(file_content)
    
if __name__=="__main__": main()