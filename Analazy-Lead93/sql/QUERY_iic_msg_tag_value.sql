-- Fixed taxonomy read query. Draft may have no selected value in a mandatory
-- Group; no default Tag Value is synthesized by this query or the Service.
SELECT g.group_code, g.group_name, g.is_mandatory, g.sort_order AS group_sort,
       v.tag_code, v.tag_name, v.description, v.sort_order AS tag_sort
FROM iic_msg_tag_group g
LEFT JOIN iic_msg_tag_value v ON v.group_code = g.group_code
ORDER BY g.sort_order, v.sort_order, v.tag_code;
