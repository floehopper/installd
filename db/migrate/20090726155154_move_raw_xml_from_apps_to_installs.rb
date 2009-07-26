class MoveRawXmlFromAppsToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :raw_xml, :text
    execute %{ UPDATE installs INNER JOIN apps ON apps.id = installs.app_id SET installs.raw_xml = apps.raw_xml, installs.updated_at = NOW() }
    remove_column :apps, :raw_xml
  end
  
  def self.down
    add_column :apps, :raw_xml, :text
    execute %{
      UPDATE
        apps,
        (SELECT raw_xml, app_id FROM installs GROUP BY app_id ORDER BY updated_at) AS raw_xml_vs_app_id
      SET
        apps.raw_xml = raw_xml_vs_app_id.raw_xml,
        apps.updated_at = NOW()
      WHERE raw_xml_vs_app_id.app_id = apps.id
    }
    remove_column :installs, :raw_xml
  end
  
end
