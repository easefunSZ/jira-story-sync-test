-- Session-scoped staging tables populated from approved business mapping files.
CREATE TEMPORARY TABLE tmp_lead93_category_seed (
  category_name varchar(100) NOT NULL,
  description varchar(500) DEFAULT NULL,
  parent_category_name varchar(100) DEFAULT NULL,
  sort_order int NOT NULL DEFAULT 0,
  PRIMARY KEY (category_name)
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_lead93_template_mapping (
  email_code varchar(100) NOT NULL,
  new_email_name varchar(200) DEFAULT NULL,
  new_description varchar(500) DEFAULT NULL,
  new_subject varchar(200) DEFAULT NULL,
  migration_action varchar(30) NOT NULL DEFAULT 'KEEP',
  action_note varchar(500) DEFAULT NULL,
  PRIMARY KEY (email_code)
) ENGINE=InnoDB;

-- Current Template-level Metadata mapping. Category/Subcategory/Tag do not
-- carry a version because they are shared by all content versions.
CREATE TEMPORARY TABLE tmp_lead93_template_category_mapping (
  email_code varchar(100) NOT NULL,
  category_name varchar(100) NOT NULL,
  PRIMARY KEY (email_code)
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_lead93_subcategory_mapping (
  email_code varchar(100) NOT NULL,
  subcategory_name varchar(100) NOT NULL,
  PRIMARY KEY (email_code, subcategory_name)
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_lead93_tag_mapping (
  email_code varchar(100) NOT NULL,
  group_code varchar(50) NOT NULL,
  tag_code varchar(100) NOT NULL,
  PRIMARY KEY (email_code, group_code, tag_code)
) ENGINE=InnoDB;

-- Convert the approved Category Framework and Template Tag Mapping files
-- into INSERT statements for these temporary tables.
