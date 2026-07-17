-- Session-scoped staging tables populated from approved business mapping files.
CREATE TEMPORARY TABLE tmp_lead93_category_seed (
  category_code varchar(50) NOT NULL,
  category_name varchar(100) NOT NULL,
  description varchar(500) DEFAULT NULL,
  parent_category_code varchar(50) DEFAULT NULL,
  category_level tinyint unsigned NOT NULL,
  sort_order int NOT NULL DEFAULT 0,
  PRIMARY KEY (category_code)
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

-- One row per Template Version that receives a main Category. The approved
-- mapping must provide version explicitly; the script never copies one
-- Template-level mapping to all historical versions by assumption.
CREATE TEMPORARY TABLE tmp_lead93_version_category_mapping (
  email_code varchar(100) NOT NULL,
  version varchar(10) NOT NULL,
  category_code varchar(50) NOT NULL,
  PRIMARY KEY (email_code, version)
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_lead93_subcategory_mapping (
  email_code varchar(100) NOT NULL,
  version varchar(10) NOT NULL,
  subcategory_code varchar(50) NOT NULL,
  PRIMARY KEY (email_code, version, subcategory_code)
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_lead93_tag_mapping (
  email_code varchar(100) NOT NULL,
  version varchar(10) NOT NULL,
  group_code varchar(50) NOT NULL,
  tag_code varchar(100) NOT NULL,
  PRIMARY KEY (email_code, version, group_code, tag_code)
) ENGINE=InnoDB;

-- Convert the approved Category Framework and Template Tag Mapping files
-- into INSERT statements for these temporary tables.
