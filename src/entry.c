extern void nusa_notch_init(void);

__attribute__((constructor))
static void NusaNotchEntry(void) {
    nusa_notch_init();
}
