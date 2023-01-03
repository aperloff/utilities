ec2-jupyter ()
{
    ssh -J aperloff@cmslpc-sl7.fnal.gov -L localhost:9999:localhost:9999 ec2-user@"$1"
}
fnal-jupyter ()
{
    echo "Start jupyter with:"
    echo -e "\tjupyter notebook --no-browser --port=${1:=8888} --ip 127.0.0.1"
    ssh -L localhost:${1:=8888}:localhost:${1:=8888} aperloff@cmslpc-sl7.fnal.gov
}
alias start_jupyter='jupyter notebook --no-browser --port=9999'
alias list_jupyter_kernels='jupyter kernelspec list'
delete_jupyter_kernel ()
{
    jupyter kernelspec uninstall ${1}
}
