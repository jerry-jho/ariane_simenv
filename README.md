# ariane_simenv
A very fast simulation of ariane risc-v cpu 

## Setup

On Linux (Ubuntu or CentOS) or WSL

1. Requires Python3 (with yaml) and Synopsys VCS & Verdi
2. Download a 64bit risc-v gcc toolchain from SiFive
3. Get source code

		git clone https://github.com/jerry-jho/ariane_local
		git clone https://github.com/jerry-jho/ariane_simenv
  
4. Edit setup.bash or setup.csh, set your repo location and risc-v gcc, and source this file.

## RTL simulation

1. cd ariane_simenv/simdir
2. *make vcs* to build the rtl with testbench
3. *make sim* to build default firmware and run simulation
4. *make verdi* to see the waveform

## Important options

1. *make sim APP=foo* will build app in ariane_simenv/tests/foo
2. *make sw APP=foo* only builds firmware
