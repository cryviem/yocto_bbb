#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/gpio/consumer.h>

struct joeleds_dev_handler_t {
    char label[20];
    struct gpio_desc *pdesc;
    struct device *pdev;
};

struct joeleds_drv_handler_t {
    struct class *pclass;
    struct device **devs; //PENDING: need to move out of driver handler, it should link with HW device
    int num_of_dev;
};

static struct joeleds_drv_handler_t drv_handler;

ssize_t direction_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    char *ret_str;
    struct joeleds_dev_handler_t *pjdev_hdl = (struct joeleds_dev_handler_t*)dev_get_drvdata(dev);
    int ret = gpiod_get_direction(pjdev_hdl->pdesc);
    if (ret < 0) {
        pr_err("direction_show > failed to get direction from %s, error %d\n", pjdev_hdl->label, ret);
        return ret;
    }

    ret_str = (ret == 0)? "out":"in";
    pr_info("direction_show > direction of %s is %s\n",pjdev_hdl->label, ret_str);
    return sprintf(buf, "%s", ret_str);
}
ssize_t direction_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    int ret;
    struct joeleds_dev_handler_t *pjdev_hdl = (struct joeleds_dev_handler_t*)dev_get_drvdata(dev);
    if (sysfs_streq(buf, "in"))
    {
        ret = gpiod_direction_input(pjdev_hdl->pdesc);
    }
    else if (sysfs_streq(buf, "out"))
    {
        ret = gpiod_direction_output(pjdev_hdl->pdesc, 0);
    }
    else
    {
        pr_err("direction_store > invalid input %s\n", buf);
        ret = -EINVAL;
    }
    pr_info("direction_store > set direction to %s return %d\n",pjdev_hdl->label, ret);
    return (ret < 0)? ret : count;
}

ssize_t value_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    struct joeleds_dev_handler_t *pjdev_hdl = (struct joeleds_dev_handler_t*)dev_get_drvdata(dev);
    int ret = gpiod_get_value(pjdev_hdl->pdesc);
    if (ret < 0) {
        pr_err("value_show > failed to get value of %s, error %d\n",pjdev_hdl->label, ret);
        return ret;
    }
    pr_info("value_show > value of %s is %d\n", pjdev_hdl->label, ret);
    return sprintf(buf, "%d", ret);
}
ssize_t value_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    int ret;
    long lvalue;
    struct joeleds_dev_handler_t *pjdev_hdl = (struct joeleds_dev_handler_t*)dev_get_drvdata(dev);
    ret = kstrtol(buf, 10, &lvalue);
    if (ret < 0)
    {
        pr_err("value_store > failed to convert %s to int, error %d\n", buf, ret);
        return ret;
    }
    else if (lvalue == 0 || lvalue == 1)
    {
        pr_info("value_store > set %s to value %d\n", pjdev_hdl->label, lvalue);
        gpiod_set_value(pjdev_hdl->pdesc, lvalue);
        return count;
    }
    else
    {
        pr_err("value_store > invalid converted int %d\n", lvalue);
        return -EINVAL;
    }
}

ssize_t label_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    struct joeleds_dev_handler_t *pjdev_hdl = (struct joeleds_dev_handler_t*)dev_get_drvdata(dev);
    pr_info("label_show > label is %s\n", pjdev_hdl->label);
    return sprintf(buf, "%s", pjdev_hdl->label);
}

DEVICE_ATTR_RW(direction);
DEVICE_ATTR_RW(value);
DEVICE_ATTR_RO(label);

/* NULL terminated list of pointer of attributes */
static struct attribute *joe_attr[] = {
    &dev_attr_direction.attr,
    &dev_attr_value.attr,
    &dev_attr_label.attr,
    NULL
};

static struct attribute_group joe_att_group = {
    /* struct attribute	**attrs; pointer to null terminated list of pointer of attribute*/
    .attrs = joe_attr
};

static const struct attribute_group *joe_att_groups[] = {
    &joe_att_group,
    NULL
};

int joeleds_probe(struct platform_device* pdev)
{
    int ret, i = 0;
    pr_info("joeleds_probe is called\n");

    /* 1 parse device tree information */
    struct device_node* parent = pdev->dev.of_node;
    struct device_node* child = NULL;
    struct joeleds_dev_handler_t* pdevdata;
    drv_handler.num_of_dev = of_get_child_count(parent);
    pr_info("joeleds_probe > number of child nodes %d\n", drv_handler.num_of_dev);
    drv_handler.devs = devm_kmalloc(&pdev->dev, sizeof(struct device*) * drv_handler.num_of_dev, GFP_KERNEL);
    /* for_each_available_child_of_node(parent, child): looping through available child nodes */
    for_each_available_child_of_node(parent, child)
    {
        pr_info("joeleds_probe > we have available child here %d\n", i);
        /* inside here is available child */
        /*child {
			label = "joe-led-0";
			joe-gpios = <&gpio1 21 GPIO_ACTIVE_HIGH>;
		} */
        const char* label;
        /* allocate device handler */
        pdevdata = devm_kmalloc(&pdev->dev, sizeof(struct joeleds_dev_handler_t), GFP_KERNEL);
        if (pdevdata == NULL)
        {
            pr_err("joeleds_probe > failed to allocate joeleds_dev_handler_t object\n");
            return -ENOMEM;
        }

        /* get label */
        if (of_property_read_string(child, "label", &label))
        {
            snprintf(pdevdata->label, sizeof(pdevdata->label), "unknown");
            pr_warn("joeleds_probe > failed to read label\n");
        } 
        else
        {
            strncpy(pdevdata->label, label, sizeof(pdevdata->label));
            pr_info("joeleds_probe >  led label is %s\n", pdevdata->label);
        }

        /* get gpio descriptor */
        pdevdata->pdesc = devm_fwnode_get_gpiod_from_child(&pdev->dev, "joe", &child->fwnode, GPIOD_ASIS, pdevdata->label);
        if (IS_ERR(pdevdata->pdesc)) {
            ret = PTR_ERR(pdevdata->pdesc);
            pr_err("joeleds_probe > failed to get gpio descriptor, error: %d\n", ret);
            return ret;
        }

        /* setting this pin as output */
        ret = gpiod_direction_output(pdevdata->pdesc, 0);
        if (ret != 0) 
        {
            pr_err("joeleds_probe > failed to set gpio output, error: %d\n", ret);
        }

        /* create logical device to interface with user space */
        /* dev num is 0 here to do not create /dev/ file */
        //pdevdata->pdev = create_device(drv_handler.pclass, &pdev->dev, 0, NULL, "led%d", i);
        pdevdata->pdev = device_create_with_groups(drv_handler.pclass, &pdev->dev, 0, pdevdata, joe_att_groups, "led%d", i);
        if (IS_ERR(pdevdata->pdev)) {
            ret = PTR_ERR(pdevdata->pdev);
            pr_err("joeleds_probe > failed to create logical device, error: %d\n", ret);
            return ret;
        }

        pr_info("joeleds_probe > registered led%d with label %s\n", i, pdevdata->label);
        drv_handler.devs[i] = pdevdata->pdev;
        i++;
    }

    pr_info("joeleds_probe > end with number of handled childs: %d\n", i);
    return 0;
}

int joeleds_remove(struct platform_device* pdev)
{
    pr_info("joeleds_remove is called\n");
    int i;
    for (i = 0; i < drv_handler.num_of_dev; i++)
    {
        device_unregister(drv_handler.devs[i]);
    }
    return 0;
}

/* compatible device strings */
static const struct of_device_id match_joe_leds[] = {
    {.compatible = "joe,led-control"},
    {}
};

static struct platform_driver joeleds_driver =
{
    .probe = joeleds_probe,
    .remove = joeleds_remove,
    .driver = {
        .name = "joe-leds",
        .of_match_table = match_joe_leds}
};

static int __init joeleds_init(void) /* Constructor */
{
    int ret;
    pr_info("joeleds_init > joe leds driver loaded\n");
    /* create class joe */
    drv_handler.pclass = class_create(THIS_MODULE, "joe");
    if (IS_ERR(drv_handler.pclass))
    {
        ret = PTR_ERR(drv_handler.pclass);
        pr_warn("joeleds_init > failed to create class, err %d\n", ret);
        return ret;
    }

    ret = platform_driver_register(&joeleds_driver);
    if (ret != 0) {
        pr_warn("joeleds_init > failed to register driver, err %d\n", ret);
    }
    return ret;
}

static void __exit joeleds_exit(void) /* Destructor */
{
    pr_info("Goodbye: joe leds driver unloaded\n");
    platform_driver_unregister(&joeleds_driver);
    class_destroy(drv_handler.pclass);
}

module_init(joeleds_init);
module_exit(joeleds_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Nguyen Hong An");
MODULE_DESCRIPTION("Joe leds simple driver");
MODULE_INFO(intree, "Y");
