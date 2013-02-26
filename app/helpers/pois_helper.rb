module PoisHelper

  def poi_table_row(record, column, name = '', data_override = nil)
    unless record.send(column).blank?
      markaby do
        tr :class => cycle('odd', 'even') do
          td.item_header {name.blank? ? column.humanize : name}
          td.item_data   {data_override.nil? ? record.send(column) : data_override}
        end
      end
    end
  end

end
