# Biobox builder helper virtual machine

This project provides a virtual machine and associated scripts to help test
your assembler Docker containers as you are building them.

## Requirements

This project requires that Vagrant and Virtualbox are installed on your
machine. These are the download links for [vagrant][1] and [virtualbox][2].
This software also requires ssh, wget, xz, rsync, GNU Make and gzip. Most
systems come with these already installed. On Mac OSX you may need to install
wget.

[1]: https://www.vagrantup.com/downloads.html
[2]: https://www.virtualbox.org/wiki/Downloads

## Quick Start

    ./script/bootstrap
    ./script/init
    make ssh
    test_image nucleotides/velvet default

## Boostrapping test data

Your images can be tested with a small read library of 20000 pairs from
Halovivax ruber. These are real reads from 2x150 sequencing on a HiSeq
generated here at the JGI. Run the script:

    ./script/bootstrap

This will download the reads in xz format and recompress them into gz format.
The gzipped reads will be placed in `mount/data`. Anything under the directory
`mount` will be mounted and available in the virtual machine (VM).

## Launching the virtual machine

The virtual machine is managed by Vagrant on top of the Virtual Box provider.
The file `Vagrantfile` manages the virtual machine, however you do not need to
understand this file unless you wish to change the CPU or memory settings of
the VM. The VM can be started by running the following:

    ./script/init

This may take sometime as an Ubuntu base box will be downloaded first, and the
VM is provisioned with Docker. Once this completes you will have a working VM
running Docker on your computer. You can now use this VM to build and test your
Docker images.

## Testing a Docker assembler image

You can log into the VM with the following command:

    make ssh

Once inside you can test running an assembler image:

    test_image nucleotides/velvet default

This will pull the nucleotides velvet image from hub.docker.com and then run it
on the test data downloaded and mounted in the image. The final lines of the
output of the command will look something like:

    .
    .
    .
    [55.466016] Initial node count 11970
    [55.466052] Removed 0 null nodes
    [55.466060] Concatenation over!
    [55.469276] Writing contigs into /tmp/tmp.y9ij5wVOyJ/contigs.fa...
    [55.695997] Writing into stats file /tmp/tmp.y9ij5wVOyJ/stats.txt...
    [55.730173] Writing into graph file /tmp/tmp.y9ij5wVOyJ/LastGraph...
    [56.017854] Estimated Coverage cutoff = 6.334071
    Final graph has 11970 nodes and n50 of 744, max 7802, total 3110693, using 0/400000 reads
    + cp /tmp/tmp.y9ij5wVOyJ/contigs.fa /outputs/contigs.fa
    + finish
    ++ cat /tmp/tmp.CTFn9KMHqk/cidfile
    + docker rm e7e87c9a9888e8fc07bc57fab75010635fb0c82bf210a101ed1eb4d4e4b0947f
    e7e87c9a9888e8fc07bc57fab75010635fb0c82bf210a101ed1eb4d4e4b0947f
    + echo /tmp/tmp.NSzIpSbLQ7
    /tmp/tmp.NSzIpSbLQ7

This shows the output of the velvet assembler. The last line show the directory
head the contigs were assembled. The following command can be run to confirm
this:

    head /tmp/tmp.NSzIpSbLQ7/contigs.fa

    >NODE_2_length_314_cov_16.732485
    GAGGTCGCGGCCGACGAGTTCGTCACCGTCGTCTCGCTCGCGATAGGCGACCACCGTCTC
    GCCGTCGGACCCCATCGCCAACTCGCCGCTCGCGAGCGGGCCGGCGGCCGTGGGTTCGCC
    AGTGGCGGCTTCGAGCGTCCCGACGTCGCGTCCGTCGGGCGGATACGCGAAGACGAGGCT
    ATCGACGACGAGTGGATCGATACCCGATTTGGCACCGACCGCTCGCTCCCACGCGATCGA
    CGGCTCACCATCGGGTCCGGAGCCGTCCGTCGCCGCAGTGTTTTCCGGGGTGGCCCGGTG
    TAGCAGCCACTCGCCGTCGACTCGCTCGTCGA

The name of the output directory will be different each time as this is a
temporary directory.

## Building your own Docker assembler image

Most likely, you are reading this because you would like to build a Docker
image of an assembler. This final part will guide you through the basics of
building an assembler. Start by cloning the git repository for the same velvet
image:

    mkdir tmp
    git clone https://github.com/nucleotides/docker-velvet tmp/velvet
    cd velvet

This directory contains the `Dockerfile` required to build the velvet image. If
you examine this file it contains instructions for building and installing
velvet using the aptitude package manager. The file `run` is the instructions
for running velvet inside the container. Run the following command to build the
velvet image and tag it as 'my_image'

    docker build -t 'my_image' .

You should now see the new velvet image listed when you run the following
command:

    docker images

You can ssh into a container of your image to see the contents inside:

    ssh_image my_image

When you run this command you will be inside the container, so you can test to
see that velvet is installed. For instance:

    velvetg

You can also see that the test reads are mounted in this container too:

    ls /inputs

Exit the container:

    exit

You can test that this container assembles the reads using the same command as
previously, but with the name of your image:

    test_image my_image default

This will run the Docker image you just constructed against the test data.

## Troubleshooting

If you are having problems build assembler images please consult the [Docker
documentation][3] or you can ask questions on the [nucleotid.es mailing
list][4].

[3]: https://docs.docker.com/
[4]: http://nucleotid.es/mailing-list/
