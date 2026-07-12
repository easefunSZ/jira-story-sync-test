-- Fixed taxonomy read query.
SELECT
  g.group_code, g.group_name, g.is_mandatory, g.sort_order AS group_sort,
  v.tag_code, v.tag_name, v.is_default, v.sort_order AS tag_sort
FROM iic_msg_tag_group g
LEFT JOIN iic_msg_tag_value v
  ON v.group_code = g.group_code
 AND v.status = 0
WHERE g.status = 0
ORDER BY g.sort_order, v.sort_order, v.id;

