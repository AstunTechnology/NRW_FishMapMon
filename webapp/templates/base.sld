<?xml version="1.0" encoding="utf-8"?>
<StyledLayerDescriptor version="1.1.0">
{% for layer in layers %}
{% include layer %}
{% endfor %}
</StyledLayerDescriptor>
