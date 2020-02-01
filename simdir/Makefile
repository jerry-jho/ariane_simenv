SCRIPTS=$(ARIANE_SIMENV_ROOT)/scripts

APP=smoke

WORKDIR=work

mkwork:
	mkdir -p $(WORKDIR)    

gen_flist_verdi:mkwork
	cd $(WORKDIR) && python3 $(SCRIPTS)/ariane_yml_vcs.py $(ARIANE_SIMENV_ROOT)/src/src_files.yml verdi,ariane,tb > flist_verdi
	
verdi: mkwork gen_flist_verdi
	cd $(WORKDIR) && $(SCRIPTS)/verdi.sh -f flist_verdi -ssf top.fsdb
	
gen_flist_vcs: mkwork
	cd $(WORKDIR) && python3 $(SCRIPTS)/ariane_yml_vcs.py $(ARIANE_SIMENV_ROOT)/src/src_files.yml vcs,ariane,tb > flist_rtl
	
vcs_nowave: mkwork gen_flist_vcs
	cd $(WORKDIR) && $(SCRIPTS)/vcs.sh -f flist_rtl

vcs: mkwork gen_flist_vcs
	cd $(WORKDIR) && rm -rf top.fsdb
	cd $(WORKDIR) && $(SCRIPTS)/vcs.sh -f flist_rtl -fsdb +define+_FSDB   
sim: mkwork sw
	cd $(WORKDIR) && ./simv +MEM_IN=$(ARIANE_SIMENV_ROOT)/tests/$(APP)/app.m64
    
sw:
	cd $(ARIANE_SIMENV_ROOT)/tests/$(APP) && make -f $(ARIANE_SIMENV_ROOT)/sw/bin/Makefile
