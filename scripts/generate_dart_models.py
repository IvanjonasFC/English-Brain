import json
import os
import sys

def map_type(prop_schema, required=False):
    if not isinstance(prop_schema, dict):
        return "dynamic"

    t = prop_schema.get("type")
    fmt = prop_schema.get("format")
    ref = prop_schema.get("$ref")
    any_of = prop_schema.get("anyOf")

    if any_of:
        # Check non-null variant
        non_nulls = [s for s in any_of if isinstance(s, dict) and s.get("type") != "null"]
        if non_nulls:
            sub_t = map_type(non_nulls[0], True)
            return f"{sub_t}?"
        return "dynamic"

    if ref:
        return ref.split("/")[-1]

    if t == "integer":
        res = "int"
    elif t == "number":
        res = "double"
    elif t == "boolean":
        res = "bool"
    elif t == "string":
        if fmt in ("date-time", "date"):
            res = "DateTime"
        else:
            res = "String"
    elif t == "array":
        items = prop_schema.get("items", {})
        sub_type = map_type(items, True)
        res = f"List<{sub_type}>"
    elif t == "object":
        add_props = prop_schema.get("additionalProperties")
        if isinstance(add_props, dict):
            val_type = map_type(add_props, True)
            res = f"Map<String, {val_type}>"
        else:
            res = "Map<String, dynamic>"
    else:
        res = "dynamic"

    if not required and not res.endswith("?") and res != "dynamic":
        return f"{res}?"
    return res

def generate_models(openapi_path, output_dart_path):
    with open(openapi_path, "r", encoding="utf-8") as f:
        spec = json.load(f)

    schemas = spec.get("components", {}).get("schemas", {})
    dart_code = [
        "// GENERATED CODE - DO NOT MODIFY BY HAND",
        "// Generated from backend/openapi.json via scripts/generate_dart_models.py",
        "// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark, unnecessary_cast, dead_code, camel_case_types",
        "",
    ]

    for name, schema in schemas.items():
        if not isinstance(schema, dict):
            continue
        props = schema.get("properties", {})
        required = schema.get("required", [])

        dart_code.append(f"class {name} {{")
        # Fields
        for prop_name, prop_data in props.items():
            is_req = prop_name in required
            dart_type = map_type(prop_data, is_req)
            dart_code.append(f"  final {dart_type} {prop_name};")
        dart_code.append("")

        # Constructor
        dart_code.append(f"  const {name}({{")
        for prop_name in props.keys():
            is_req = prop_name in required
            prefix = "required " if is_req else ""
            dart_code.append(f"    {prefix}this.{prop_name},")
        dart_code.append("  });")
        dart_code.append("")

        # fromJson
        dart_code.append(f"  factory {name}.fromJson(Map<String, dynamic> json) {{")
        dart_code.append(f"    return {name}(")
        for prop_name, prop_data in props.items():
            if not isinstance(prop_data, dict):
                continue
            is_req = prop_name in required
            raw_t = prop_data.get("type")
            ref = prop_data.get("$ref")
            any_of = prop_data.get("anyOf", [])
            fmt = prop_data.get("format")

            target_ref = ref
            is_date = (fmt in ("date-time", "date"))
            is_double = (raw_t == "number")
            items_ref = None

            if raw_t == "array":
                items = prop_data.get("items", {})
                if isinstance(items, dict):
                    items_ref = items.get("$ref")

            for sub in any_of:
                if isinstance(sub, dict):
                    if sub.get("$ref"):
                        target_ref = sub.get("$ref")
                    if sub.get("format") in ("date-time", "date"):
                        is_date = True
                    if sub.get("type") == "number":
                        is_double = True

            if target_ref:
                target_cls = target_ref.split("/")[-1]
                if is_req:
                    dart_code.append(f"      {prop_name}: {target_cls}.fromJson(json['{prop_name}'] as Map<String, dynamic>),")
                else:
                    dart_code.append(f"      {prop_name}: json['{prop_name}'] != null ? {target_cls}.fromJson(json['{prop_name}'] as Map<String, dynamic>) : null,")
            elif is_date:
                if is_req:
                    dart_code.append(f"      {prop_name}: DateTime.parse(json['{prop_name}'] as String),")
                else:
                    dart_code.append(f"      {prop_name}: json['{prop_name}'] != null ? DateTime.parse(json['{prop_name}'] as String) : null,")
            elif is_double:
                if is_req:
                    dart_code.append(f"      {prop_name}: (json['{prop_name}'] as num).toDouble(),")
                else:
                    dart_code.append(f"      {prop_name}: (json['{prop_name}'] as num?)?.toDouble(),")
            elif raw_t == "array" and items_ref:
                item_cls = items_ref.split("/")[-1]
                dart_code.append(f"      {prop_name}: (json['{prop_name}'] as List<dynamic>?)?.map((e) => {item_cls}.fromJson(e as Map<String, dynamic>)).toList() ?? [],")
            elif raw_t == "array":
                dart_code.append(f"      {prop_name}: (json['{prop_name}'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],")
            elif raw_t == "object" and isinstance(prop_data.get("additionalProperties"), dict):
                dart_code.append(f"      {prop_name}: (json['{prop_name}'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {{}},")
            elif raw_t == "integer":
                if is_req:
                    dart_code.append(f"      {prop_name}: (json['{prop_name}'] as num).toInt(),")
                else:
                    dart_code.append(f"      {prop_name}: (json['{prop_name}'] as num?)?.toInt(),")
            elif raw_t == "string":
                if is_req:
                    dart_code.append(f"      {prop_name}: json['{prop_name}'] as String,")
                else:
                    dart_code.append(f"      {prop_name}: json['{prop_name}'] as String?,")
            elif raw_t == "boolean":
                if is_req:
                    dart_code.append(f"      {prop_name}: json['{prop_name}'] as bool,")
                else:
                    dart_code.append(f"      {prop_name}: json['{prop_name}'] as bool?,")
            else:
                dart_code.append(f"      {prop_name}: json['{prop_name}'],")
        dart_code.append("    );")
        dart_code.append("  }")
        dart_code.append("")

        # toJson
        dart_code.append("  Map<String, dynamic> toJson() {")
        dart_code.append("    return {")
        for prop_name, prop_data in props.items():
            if not isinstance(prop_data, dict):
                continue
            is_req = prop_name in required
            ref = prop_data.get("$ref")
            any_of = prop_data.get("anyOf", [])
            is_date = prop_data.get("format") in ("date-time", "date")
            for sub in any_of:
                if isinstance(sub, dict):
                    if sub.get("$ref"):
                        ref = sub.get("$ref")
                    if sub.get("format") in ("date-time", "date"):
                        is_date = True

            q_mark = "" if is_req else "?"
            if ref:
                dart_code.append(f"      '{prop_name}': {prop_name}{q_mark}.toJson(),")
            elif is_date:
                dart_code.append(f"      '{prop_name}': {prop_name}{q_mark}.toIso8601String(),")
            elif prop_data.get("type") == "array" and isinstance(prop_data.get("items"), dict) and prop_data.get("items", {}).get("$ref"):
                dart_code.append(f"      '{prop_name}': {prop_name}{q_mark}.map((e) => e.toJson()).toList(),")
            else:
                dart_code.append(f"      '{prop_name}': {prop_name},")

        dart_code.append("    };")
        dart_code.append("  }")
        dart_code.append("}")
        dart_code.append("")

    os.makedirs(os.path.dirname(output_dart_path), exist_ok=True)
    with open(output_dart_path, "w", encoding="utf-8") as f:
        f.write("\n".join(dart_code))
    print(f"Generated {len(schemas)} Dart models in {output_dart_path}")

if __name__ == "__main__":
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    openapi_file = os.path.join(base_dir, "backend", "openapi.json")
    out_dart = os.path.join(base_dir, "app", "lib", "core", "models", "api_models.dart")
    generate_models(openapi_file, out_dart)
