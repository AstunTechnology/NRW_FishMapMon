<?xml version="1.0" encoding="utf-8"?>
<StyledLayerDescriptor version="1.1.0">
{% for info in layer_info %}
{% include info['template'] ignore missing %}
{% endfor %}
</StyledLayerDescriptor>
