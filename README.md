# Table of contents

- [Overview](#Overview)
- [Requirements](#Requirements)
- [Supported devices](<#Supported devices">)
- [Usage](#Usage)
- [Tutorial](#Tutorial)
- [Background/History](#Background/History)

# Overview

SDTGen is a tool that implements a TCL interface to generate [System
Device
Trees](https://github.com/devicetree-org/lopper/blob/master/specification/source/chapter1-introduction.rst)
for AMD&trade; FPGAs using an XSA file as input.

# Requirements

This tool requires that you have access to [AMD Vivado&trade;  Design
Suite](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html)
or [AMD Vitis&trade; Unified Software
Platform](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vitis.html)

# Supported devices

System Device Tree Generator (SDTGen) currently only supports AMD&trade;
SoCs and designs based on ARM&trade; processors. Support for AMD
MicroBlaze&trade; Processors and AMD MicroBlaze&trade; V Processors is
limited and will not provide Linux&reg; device trees. 

# Usage 

## Flow

SDTGen requires a multi-stage approach for usage. First one needs to set
it up with parameters like input path, output path, and external DTS
files, and then running a command to generate the output. 

## Command line arguments available with SDTGen
### set_dt_param
Takes the user inputs to set the parameters needed for the system device
tree generation.
* Mandatory arguments: 
  * `-xsa` : Sets the XSA path for which SDT has to be generated. 
  * `-dir` : Sets the output directory where the SDT is to be generated.
* Optional arguments:
  * `-board_dts` : Includes the static AMD&trade; development board
  	specific DTSI file available at `<this
  	repo>/device_tree/data/kernel_dtsi/<release>/<board>` inside the
  	final SDT
  * `-include_dts` : Includes a user defined custom `.dtsi` file inside the
  	final SDT 
	* Can be used to workaround when SDTGen tool is generating
  	incorrect data, can be used to override the existing data in the
  	final SDT, or add a custom board `.dtsi` file.
  * `-trace` : Enables traces of the procs called to generate the SDT
  * `-debug` : Enables the warning prints wherever mentioned in the
  	TCL scripts 
  	* Helpful in getting more info on what might go missing
  	in the final SDT even though the SDT generation is successful.
  
#### Example
```bash
# Note that the Multiple parameter setting in one line is allowed for all the available arguments of set_dt_param.

# Set the mandatory set_dt_param arguments.
sdtgen% set_dt_param -dir outdir
sdtgen% set_dt_param -xsa design_1_wrapper.xsa

# Multiple options in a single command
sdtgen% set_dt_param -xsa system.xsa -dir sdt_outdir

# Sample optional arguments with set_dt_param

# Include board specific dtsi file from <SDT repo>/device_tree/data/kernel_dtsi/2025.1/BOARD path
# Below command copies the <SDT repo>/device_tree/data/kernel_dtsi/2025.1/BOARD/zcu102-rev1.0.dtsi file
# into SDT output directory and add include statement in system-top.dts
sdtgen% set_dt_param -board_dts zcu102-rev1.0

# Include a user defined custom dtsi file inside the final SDT
# Below command copies the custom.dtsi file into SDT output directory and add include statement in system-top.dts
sdtgen% set_dt_param -include_dts <path>/custom.dtsi

# Enable the trace i.e. the flow of TCL procs that are getting invoked during SDT generation. The default trace option is "disable".
sdtgen% set_dt_param -trace enable

# Enable the debug option to get warning prints. The default debug option is "disable".
sdtgen% set_dt_param -debug enable

# Command Help
sdtgen% set_dt_param -help
            Usage: set/get_dt_param \[OPTION\]
            -xsa              Vivado hw design file
            -board_dts        board specific file
            -dir              Directory where the dt files will be generated
            -include_dts      DTS file to be include into final device tree
            -debug            Enable DTG++ debug
            -trace            Enable DTG++ traces

# Combining everything in one command
sdtgen% set_dt_param -xsa system.xsa -dir sdt_outdir -board_dts zcu102-rev1.0 -include_dts ./custom.dtsi -trace enable -debug enable
```
### get_dt_param
Returns the values set for the given argument. Returns the default
values if the argument has not been set using the "set_dt_param". 
#### Example 
```bash
# Unlike set_dt_param, get_dt_param expects only one argument in one command.

sdtgen% get_dt_param -help
            Usage: set/get_dt_param \[OPTION\]
            -repo             system device tree repo source
            -xsa              Vivado hw design file
            -board_dts        board specific file
            -dir              Directory where the dt files will be generated
            -include_dts      DTS file to be include into final device tree
            -debug            Enable DTG++ debug
            -trace            Enable DTG++ traces


sdtgen% get_dt_param -board_dts
zcu102-rev1.0
sdtgen% get_dt_param -dir
sdt_outdir
sdtgen% get_dt_param -xsa
system.xsa
sdtgen% get_dt_param -repo
/home/abc/Xilinx/Vitis/2025.1/data/system-device-tree-xlnx
```
### generate_sdt
Generates the system device tree with the set parameters. Usage:
```bash
generate_sdt
```

## Output of SDTGen

SDTGen outputs both hardware configuration information in the form of
System Device Trees, but also binary files containing "firmware"
(initial bootloaders, hardware configuration files) for the device.

### System Device Tree files.

The generated system device tree contains following files.
* Files that are static for a given device family:	
  * soc.dtsi: A SOC specific file containing information about the CPU . e.x.: versal.dtsi
  * board.dtsi: A board file copied from AMD&trade;'s prebuilt board repository. e.x.: versal-vck190-reva
  * clk.dtsi: Clock information for the device. e.x.: versal-clk.dtsi
* Files dynamically generated based on AMD Vivado&trade; Design Suite output: 
  * pl.dtsi: Contains Programmable Logic(soft IPs) information.
  * system-top.dts: System information about memory, CPU clusters, aliases etc.
  * pcw.dtsi: Information about the configuration of the processing system from the AMD Vivado&trade;  Design Suite peripheral configuration wizard. 

### Binary files
Apart from the `.dtsi` files and `system-top.dts`, the SDTGen output directory also contains some files that are needed to configure the hardware. These files are available within XSA and are extracted and placed into the output directory.

For different platforms, extracted files are:
* Microblaze / Microblaze RISCV: - bitstream (.bit)
* Zynq:
     - ps7_inits (.c, .h, .tcl etc)
     - bitstream(.bit)
* ZynqMP:
     - psu_inits (.c, .h, .tcl etc)
     - bitstream(.bit)
* Versal:
     - PDI (.pdi)
     - A folder named "extracted" that contains:
     	- ELFs like plm, psm
     	- CDOs like lpd, fpd, pmc_data etc.
     	- bif file that can re-construct the PDI using above artifacts

## How to use custom system device tree repository path with SDTGen
### Usage of CUSTOM_SDT_REPO:
 By default SDTGen will run from the installed tool under <i>&lt;Installed
 Vitis Path&gt;</i>/2025.1/data/system-device-tree-xlnx or <i>&lt;Installed
 Vivado Path&gt;</i>/2025.1/data/system-device-tree-xlnx. If you want to use
 the local SDT repo instead of the installed one, use the environment
 variable `CUSTOM_SDT_REPO`.

```bash
# Say the local SDT repo is kept at /home/abc/local_sdt_repo/system-device-tree-xlnx
# Set the environment variable CUSTOM_SDT_REPO to the above local path to use TCL sources from this local path.
# In BASH, it can be done using export command.
# e.g.
export CUSTOM_SDT_REPO=/home/abc/local_sdt_repo/system-device-tree-xlnx

# Use the same tcl as generated above (without any change) and call sdtgen command
/home/abc/Xilinx/Vitis/2025.1/bin/sdtgen sdt.tcl design1_wrapper.xsa sdt_outdir

# This will lead to prints like below while launching SDTGen which ensures that these local tcls are being sourced
# Info: Detected Custom SDT repo path at /home/abc/local_sdt_repo/system-device-tree-xlnx Verifying...
# Successfully sourced custom SDT Repo path.
```
# Tutorial

The following shows how to use SDTGen with a helper script to create a
System Device Tree from a `.xsa` file. 

1. Determine the path of SDTGen binary path from the installed Vitis tool

	For example
	```
	/home/abc/Xilinx/Vitis/2025.1/bin/sdtgen
	```

2. Put the commands below in a TCL file (e.x. `sdt.tcl`)
	```
	set outdir [lindex $argv 1]
	set xsa [lindex $argv 0]
	exec rm -rf $outdir
	set_dt_param -xsa $xsa -dir $outdir -board_dts zcu102-rev1.0
	generate_sdt
	```

3. Run the sdtgen command to get the SDT directory

	```
	<sdtgen binary path> sdt.tcl <Vivado generated xsa path> <sdt outdir where files will be generated>
	```
	For example
	```
	<Vitis install location>/bin/sdtgen sdt.tcl design1_wrapper.xsa sdt_outdir
	```

# Background/History
## Device Tree (DT)
A [device
tree](https://www.kernel.org/doc/html/latest/devicetree/usage-model.html#linux-and-the-devicetree
) is a data structure and language for describing hardware. It is a
description of hardware that is readable by an operating system so that
the operating system doesn't need to hard code details of the machine.

## System Device Tree (SDT)
The System Device Tree is a superset of a traditional Linux-compatible
devicetree intended to support more complex software including
hypervisors and RTOSs. System Device Tree is architected to be
compatible with traditional device-tree files and acts as a superset
extension of the original syntax. In general, the System Device Tree
represents the entirety of the system, including components not
historically relevant to an individual operating system, in contrast the
regular Linux device tree represents hardware information that is only
needed for Linux/APU.

System Device Tree uses the same syntax as traditional Device Tree. 

For example, a System Device Tree can include information about the CPU
cluster and memory associated with the Cortex-R CPU cluster in a device
such as AMD Zynq&trade; UltraScale+&trade; MPSoC in addition to the
Cortex-A cluster available in traditional Device Tree.

 System Device Trees are intended to be parsed with a tool like
[Lopper](https://github.com/devicetree-org/lopper/tree/master) to allow
complex inter-software architectures to be specified in simple
configuration files. More details on the System Device Tree spec can be
found inside [devicetree-org lopper
repository](https://github.com/devicetree-org/lopper/tree/master/specification/source).

## Hardware Software Interface (HSI)
An AMD-Xilinx proprietary TCL based utility that can extract the
hardware specific data from the XSA (Xilinx Support Archive) file into a
human readable format. The extracted hardware meta-data can then be
passed on to the software world. HSI is provided by AMD Vivado&trade;
Design Suite or AMD Vitis&trade; Unified Software Platform.

More info on how to use HSI commands can be found at:

[Extracting HW info using
HSI](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841693/HSI+debugging+and+optimization+techniques#HSIdebuggingandoptimizationtechniques-ExtractingHWinfousingHSIfromtheXSCTcommandline:)
and [Internal HSI
utilities](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841693/HSI+debugging+and+optimization+techniques#HSIdebuggingandoptimizationtechniques-InternalHSIutilities:)


## SDTGen
SDTGen (this tool) is a tool that uses TCL scripts and Hardware HSI APIs
to read the hardware information from XSA and put it in System Device
Tree (SDT) format. The TCL source files for the tool is kept in present
repository and the same can be found in the install directory for AMD
Vitis&trade; Unified Software Platform or AMD Vivado&trade;  Design
Suite. 

SDTGen exports the following three procs into it's environment:

* set_dt_param
* get_dt_param
* generate_sdt


