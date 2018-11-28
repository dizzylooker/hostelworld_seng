view: order_items {
  sql_table_name: public.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

#   dimension_group: delivered {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}.delivered_at ;;
#   }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    label: "Booking ID"
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    label: "Cancelled"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    label: "Booking Value"
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_booking_value {
    type: sum
    value_format_name: eur
    sql: ${sale_price} ;;
    drill_fields: [products.name, products.id, total_booking_value]
  }

  measure: count_cancelled {
    type: count
    filters: {
      field: returned_date
      value: "-NULL"
    }
  }

  measure: booking_value_per_hit {
    type: average
    value_format_name: eur
    sql: ${sale_price} ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }

  dimension: days_until_next_booking {
    type: number
    view_label: "Repeat Booking Facts"
    sql: DATEDIFF('day',${created_raw},${repeat_purchase_facts.next_order_raw}) ;;
  }

  dimension: repeat_bookings_within_1y {
    type: yesno
    view_label: "Repeat Booking Facts"
    sql: ${days_until_next_booking} <= 365 ;;
  }

  measure: count_with_repeat_booking_within_1y {
    type: count_distinct
    sql: ${id} ;;
    view_label: "Repeat Booking Facts"

    filters: {
      field: repeat_bookings_within_1y
      value: "Yes"
    }
  }

  measure: 1_year_repeat_booking_rate {
    description: "The percentage of customers who book again within 1 year"
    view_label: "Repeat Booking Facts"
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_with_repeat_booking_within_1y} / NULLIF(${count},0) ;;
    drill_fields: [products.brand, count, count_with_repeat_booking_within_1y]
  }
}
