#
# Copyright 2015 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

LIB_IP_COMPLEX_TO_MAGPHASE_SRCS = $(IP_BUILD_DIR)/complex_to_magphase/complex_to_magphase.xci

LIB_IP_COMPLEX_TO_MAGPHASE_OUTS = $(addprefix $(IP_BUILD_DIR)/complex_to_magphase/, \
complex_to_magphase.xci.out \
synth/complex_to_magphase.vhd \
) 

$(LIB_IP_COMPLEX_TO_MAGPHASE_SRCS) $(LIB_IP_COMPLEX_TO_MAGPHASE_OUTS) : $(LIB_IP_DIR)/complex_to_magphase/complex_to_magphase.xci
	$(call BUILD_VIVADO_IP,complex_to_magphase,$(ARCH),$(PART_ID),$(LIB_IP_DIR),$(IP_BUILD_DIR),0)
