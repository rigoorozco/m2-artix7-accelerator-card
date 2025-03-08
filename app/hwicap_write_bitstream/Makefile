CC ?= gcc

SRCS = \
xhwicap.c \
xhwicap_selftest.c \
xhwicap_srp.c \
hwicap_write_bitstream.c

all: hwicap_write_bitstream

hwicap_write_bitstream:
	$(CC) $(SRCS) -o $@

clean:
	rm -rf hwicap_write_bitstream
