obj-m := choen.o

SRC := $(shell pwd)
# KERNEL_SRC is automatically initialized by module.bbclass to STAGING_KERNEL_DIR (tmp/work-shared/kernel-source)

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC)

modules_install:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC) modules_install

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions Modules.symvers