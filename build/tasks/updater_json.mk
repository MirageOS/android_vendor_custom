MIRAGE_JSON := $(PRODUCT_OUT)/$(TARGET_DEVICE).json

$(MIRAGE_JSON): $(CUSTOM_TARGET_PACKAGE)
	@vendor/custom/build/tools/gen_updater_json.sh $(PRODUCT_OUT) $(TARGET_DEVICE)

.PHONY: mirage bacon otapackage
mirage bacon otapackage: $(MIRAGE_JSON)
