MIRAGE_JSON := $(PRODUCT_OUT)/$(TARGET_DEVICE).json

$(MIRAGE_JSON): $(INTERNAL_OTA_PACKAGE_TARGET)
	@vendor/custom/build/tools/gen_updater_json.sh $(PRODUCT_OUT) $(TARGET_DEVICE)

.PHONY: bacon otapackage
bacon otapackage: $(MIRAGE_JSON)
