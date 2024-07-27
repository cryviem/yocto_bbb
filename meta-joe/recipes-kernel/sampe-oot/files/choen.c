#include <linux/module.h>
#include <linux/init.h>
#include <linux/version.h>
#include <linux/kernel.h>

/* Call on install*/
static int __init choen_init(void) /* Constructor */
{
    pr_info("Hello: choen registered\n");
    return 0;
}

/* Call on uninstall*/
static void __exit choen_exit(void) /* Destructor */
{
    pr_info("Goodbye: choen unregistered\n");
}

module_init(choen_init);
module_exit(choen_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Andy");
MODULE_DESCRIPTION("Just a sample loadable module");