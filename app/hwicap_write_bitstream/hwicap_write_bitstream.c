/***************************** Include Files *********************************/

#include "xparameters.h"	/* XPAR parameters */
#include "xhwicap.h"		/* HwIcap device driver */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <byteswap.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <ctype.h>

#include <sys/types.h>
#include <sys/mman.h>

/************************** Constant Definitions *****************************/

/************************** Variable Definitions *****************************/

/*
 * The following variables are used to read and write to the  HwIcap device, they
 * are global to avoid having large buffers on the stack.
 */

static XHwIcap HwIcapInstance;	/* The instance of the HwIcap device */

/*****************************************************************************/
/**
*
* Main function to write bitstream to HwIcap.
*
* @param    None
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None
*
******************************************************************************/
int main(int argc, char **argv)
{
    int fd;
    int err = 0;
    void *map;

    off_t target;
    off_t pgsz, target_aligned, offset;
    char *device;
    char *bitstream;

    int status;

    FILE* file;
    int file_size_bytes;
    int file_size_words;

    /* not enough arguments given? */
    if (argc < 4) {
        fprintf(stderr,
            "Usage:\t%s <device> <address> <bitstream>\n"
            "\tdevice    : character device to access\n"
            "\taddress   : memory address to access\n"
            "\tbitstream : path to bitstream\n",
            argv[0]);
        exit(1);
    }

    device = strdup(argv[1]);
    target = strtoul(argv[2], 0, 0);
    bitstream = strdup(argv[3]);

    /* check for target page alignment */
    pgsz = sysconf(_SC_PAGESIZE);
    offset = target & (pgsz - 1);
    target_aligned = target & (~(pgsz - 1));

    if ((fd = open(device, O_RDWR | O_SYNC)) == -1) {
        printf("character device %s open failed: %s.\n",
            device, strerror(errno));
        return -errno;
    }
    printf("character device %s opened.\n", device);

    if ((file = fopen(bitstream, "rb")) == NULL) {
        printf("bitstream file %s open failed: %s.\n",
            device, strerror(errno));
        return -errno;
    }
    printf("bitstream file %s opened.\n", device);

    /* Get size of file */
    fseek(file, 0L, SEEK_END);
    file_size_bytes = ftell(file);
    fseek(file, 0L, SEEK_SET);
    file_size_words = file_size_bytes/sizeof(uint32_t);

    /* Copy file contents to buffer */
    uint32_t buffer[file_size_words];
    for (int i; i < file_size_words; i++) {
        if (fread(&buffer[i], sizeof(uint32_t), 1, file) != 1) {
            printf("reading from bitstream file failed: %s.\n", strerror(errno));
            return -errno;
        }
    }
    printf("bitstream file was copied to buffer.\n");

    /* Memory map HWICAP register space */
    map = mmap(NULL, offset + 4, PROT_READ | PROT_WRITE, MAP_SHARED, fd, target_aligned);
    if (map == (void *)-1) {
        printf("Memory 0x%lx mapped failed: %s.\n",
        target, strerror(errno));
        err = 1;
        goto close;
    }
    printf("Memory 0x%lx mapped at address %p (offset %lx).\n", target_aligned, map, offset);

    map += offset;

    /* Pass the address we just got to config struct */
    XHwIcap_Config ConfigPtr = {
        0,   /* Device ID of device */
        map, /* Register base address */
        32,  /* Width of ICAP */
        0    /* IsLiteMode: 0 not present, 1 present */
    };

    /*
     * Run the HwIcap initialization.
     */
    status = XHwIcap_CfgInitialize(&HwIcapInstance, &ConfigPtr, ConfigPtr.BaseAddress);
    if (status != XST_SUCCESS) {
        printf("HWICAP configuration failed!\r\n");
        return XST_FAILURE;
    }

    /*
     * Perform a self-test to ensure that the hardware was built correctly.
     */
    status = XHwIcap_SelfTest(&HwIcapInstance);
    if (status != XST_SUCCESS) {
        printf("HWICAP self test failed!\r\n");
        return XST_FAILURE;
    }
    printf("Self test finished successfully!\n");

    /*
     * Write the the data to the device.
     */
    status = XHwIcap_DeviceWrite(&HwIcapInstance, (uint32_t *) &buffer[0], file_size_words);
    if (status != XST_SUCCESS) {
        printf("HWICAP device write failed!\r\n");
        return XST_FAILURE;
    }

    printf("Successfully ran HWICAP device write!\r\n");
    return XST_SUCCESS;

close:
    close(fd);
    return err;
}
