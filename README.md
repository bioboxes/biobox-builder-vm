# Biobox builder helper virtual machine

This project provides a virtual machine with Docker install and additional
scripts to help you build and test your biobox Docker containers.

## Requirements

This project requires that Vagrant and Virtualbox are installed on your
machine. These are the download links for [vagrant][1] and [virtualbox][2].
This software also requires ssh, rsync, and GNU Make. If you are using Linux or
Mac OSX these should already be installed.

[1]: https://www.vagrantup.com/downloads.html
[2]: https://www.virtualbox.org/wiki/Downloads

## Quick start

    ./script/init
    make ssh
    biobox verify short_read_assembler bioboxes/velvet

## Launching the virtual machine

The virtual machine is managed by Vagrant on top of the Virtual Box. The file
`Vagrantfile` specifies the virtual machine, however you do not need to
understand this file unless you wish to change the CPU or memory settings. The
VM can be started by running the following:

    ./script/init

This may take sometime as an Ubuntu base box will be downloaded first, and
necessary packages are install. Once this completes you will have a working VM
running Docker on your computer. You can now use this VM to build and test your
biobox Docker images. When you are finished with the VM you can turn it off
with the command:

    make down

## Building and testing a Docker assembler image

You can log into the VM with the following command:

    make ssh

Once inside you can test an already existing biobox image as follows:

    biobox verify short_read_assembler biobox/velvet

This uses the [biobox command line tool][tool] to verify that the biobox/velvet
image conforms to the biobox specification.

[tool]: https://github.com/bioboxes/command-line-interface

This will pull the [bioboxes/velvet][velvet] image from DockerHub and then test
the image with various scenarios such as with both and invalid and valid input
data. This produces no output when the image is valid, and returns an error
message when the biobox is not valid.

[velvet]: https://github.com/bioboxes/velvet

## Building your own Docker assembler image

Most likely, you are reading this because you would like to build a biobox
Docker image. As an example of how to do this, this start by cloning the git
repository for the [velvet assembler image][velvet]:

    mkdir tmp
    git clone https://github.com/nucleotides/docker-velvet tmp/velvet
    cd velvet

This cloned directory contains the `Dockerfile` required to build the velvet
image. If you examine this file it contains instructions for building and
installing velvet inside a Docker image using the aptitude package manager. The
file `assemble` is the instructions for running velvet inside the container.
Run the following command to build the velvet image and tag it as 'my_image'

    docker build --tag 'my_image' .

You can now test that the built image is valid command as above, but using the
name of this image:

    biobox verify short_read_assembler my_image

## Troubleshooting

If you are having problems build assembler images please consult the [Docker
documentation][docker], the [bioboxes developer documentation][dev], or ask
questions on the [bioboxes issue tracker][ghi].

[dev]: http://bioboxes.org/guide/developer/
[ghi]: https://github.com/bioboxes/rfc/issues
[docker]: https://docs.docker.com/
