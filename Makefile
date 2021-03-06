EXTOPENSCAD=../ImplicitCAD/dev/ImplicitCAD-current/dist-newstyle/build/x86_64-linux/ghc-8.8.4/implicit-0.3.0.1/x/extopenscad/build/extopenscad/extopenscad
EXTCURAENGINE=../HSlice/HSlice-current/dist-newstyle/build/x86_64-linux/ghc-8.8.4/hslice-0.0.1/x/extcuraengine/build/extcuraengine/extcuraengine
PROFEXTCURAENGINE=../HSlice/HSlice-current/dist-newstyle/build/x86_64-linux/ghc-8.8.4/hslice-0.0.1/x/extcuraengine/build/extcuraengine/extcuraengine

TARGETS=LM2596_DC_DC_Converter.stl lulzbot_tool_holding_plate.stl lulzbot_long_bearing_holder.stl 

PROFILE_OPTS=-hc -i0.5

#RTSOPTS?=+RTS -t
RTSOPTS?=+RTS -N -qg -t 

PRINTER_Z_RES?=0.1

PRINTER_OPTS= -s machine_width=200 -s machine_depth=200 -s machine_height=100 -s machine_nozzle_size=0.35 -s material_diameter=2.85 -s outer_inset_first=False -s infill_sparse_density=100

TEST_ESCADS=$(shell bash -c "cd Tests && find ./ -name '*.escad'" | sort)

SCADOPTS=-r ${PRINTER_Z_RES} -f asciistl

STLOPTS=-s layer_height=${PRINTER_Z_RES} ${PRINTER_OPTS}

.PHONY: clean all

all: ${TARGETS}

clean:
	rm -f *.stl *.gcode
	rm -f *~
	rm -f *.hp *.ps
	rm -f Tests/*.stl
	rm -f Tests/*.gcode
	rm -f Tests/*.hp
	rm -f Tests/*.ps

#	find ./ -name *.svg | xargs rm

tests: ${PROFEXTCURAENGINE} ${EXTOPENSCAD}
	cd Tests && for each in ${TEST_ESCADS}; do { echo $$each ; ../$(EXTOPENSCAD) ${SCADOPTS} $$each -o $${each%.escad}.stl $(RTSOPTS); time ../${PROFEXTCURAENGINE} slice -l $${each%.escad}.stl -o $${each%.escad}.gcode ${STLOPTS} ${RTSOPTS} $(PROFILE_OPTS) ; } done

%.stl: %.escad
	bash -c "time ${EXTOPENSCAD} ${SCADOPTS} $< -o $@ ${RTSOPTS}"

%.gcode: %.stl
	${EXTCURAENGINE} slice -l $< -o $@ ${STLOPTS} ${RTSOPTS}

%.gcode.hp: %.stl
	${PROFEXTCURAENGINE} slice -l $< -o $*.gcode ${STLOPTS} ${RTSOPTS} $(PROFILE_OPTS)
	mv extcuraengine.hp $*.gcode.hp

%.gcode.ps: %.gcode.hp
	hp2ps -c -d -e8in $*.gcode
