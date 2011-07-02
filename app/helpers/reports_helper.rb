module ReportsHelper

  def overdue_user_to_array(user)
    a = []
    a << user.email
    a << user.primary_attendee.get_full_name
    a << user.created_at.to_date.to_formatted_s
    a << user.get_initial_deposit_due_date.to_formatted_s
    a << user.attendees.count
    a << user.attendees.where('deposit_received_at is not null').length
    return a
  end

  def transaction_to_array(t)
    a = []
    a << t.created_at.to_date
    a << t.get_trantype_name
    a << t.amount
    a << t.user.email
    a << t.user.primary_attendee.get_full_name
    a << t.gwtranid
    a << t.check_number
    a << (t.updated_by_user.present? ? t.updated_by_user.primary_attendee.given_name : nil)
    a << t.updated_at.to_date
    a << (t.gwdate.present? ? t.gwdate.to_date : nil)
    a << (t.comment.present? ? html_escape(t.comment) : nil)
    return a
  end

  def attendee_to_array(a)
    ar = []

    # basic user attributes
    %w[email].each do |attr|
      if a.user.blank? || a.user[attr].blank?
        ar << nil
      else
        ar << a.user[attr]
      end
    end

    # basic attendee attributes
    a.attribute_names_for_csv.each do |attr|
      if a[attr].blank?
        ar << nil
      else
        if attr == 'rank'
          ar << a.get_rank_name
        elsif attr == 'tshirt_size'
          ar << a.get_tshirt_size_name
        else
          # entity encode things like angle brackets, or else 
          # excel may fail to open the csv correctly
          ar << html_escape(a[attr])
        end
      end
    end

    # lisa says: plans should come right after attendee attrs
    pqh = a.plan_qty_hash
    Plan.order(:name).each do |p|
      plan_qty = pqh[p.id].present? ? pqh[p.id].to_i : 0
      ar << plan_qty.to_i
    end

    # claimed discounts
    claimed_discount_ids = a.discounts.where('is_automatic = ?', false).map { |d| d.id }
    claimable_discounts = Discount.where('is_automatic = ?', false).order(:name)
    claimable_discounts.each do |d|
      ar << claimed_discount_ids.index(d.id).present? ? 'yes' : 'no'
    end

    return ar
  end

end
