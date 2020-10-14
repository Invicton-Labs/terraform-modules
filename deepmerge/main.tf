locals {
    // Find the greatest depth through the maps
    greatest_depth = max(concat([
        for mod in local.modules:
            concat([
                for i in range(0, length(var.maps)):
                    [
                        for f in mod[i].fields:
                        length(f["path"])
                    ]
            ]...)
    ]...)...)

    fields_json = [
        for i in range(0, length(var.maps)):
        merge([
            for j in range(0, local.greatest_depth):
            {
                for f in local.modules[j][i].fields:
                jsonencode(f.path) => f
            } 
        ]...)
    ]
    merged_map = merge(local.fields_json...)
/*
    merged_fields = merge([
        for field in local.merged_map:
        {
            for path_length in range(1, length(field.path) + 1):
            jsonencode(slice(field.path, 0, path_length)) => {
                key = jsonencode(slice(field.path, 0, path_length))
                is_final = field.is_final
                path = slice(field.path, 0, path_length)
                value = field.is_final ? field.value : null
            }
        }
    ]...)
*/
    merged_fields_by_depth = {
        for depth in range(0, local.greatest_depth):
        depth => {
        for key in keys(local.merged_map):
            key => local.merged_map[key]
            if length(local.merged_map[key].path) == depth + 1
        }
    }
/*
    all_fields_by_depth = {
        for depth in range(0, local.greatest_depth):
        depth => {
        for key in keys(local.all_fields):
            key => local.all_fields[key]
            if length(local.all_fields[key].path) == depth + 1
        }
    }
*/
    m0 = {
        for field in local.merged_fields_by_depth[0]:
        field.path[0] => {final_val = field.value, sub_val = lookup(local.m1, field.key, null)}[field.is_final ? "final_val" : "sub_val"]
    }
}

// Check to make sure the highest level module has no remaining values that weren't recursed through
module "asset_sufficient_levels" {
    source = "../assert"
    error_message = "Deepmerge has recursed to insufficient depth (${length(local.modules)} levels is not enough)"
    condition = concat([
        for i in range(0, length(var.maps)):
        local.modules[length(local.modules) - 1][i].remaining
    ]...) == []
}

// Uncomment this to generate a new file with a different max depth
/*
resource "local_file" "depth" {
    content     = templatefile("${path.module}/../deepmerge/depth.tmpl", {max_depth = 100})
    filename = "${path.module}/../deepmerge/depth.tf"
}
*/
