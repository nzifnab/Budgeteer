module AccountsHelper
  def display_type( current_account, highlight_account )
    if highlight_account && highlight_account.id == current_account.id
      "highlight"
    elsif current_account.enabled
      "even"
    else
      "disabled"
    end
  end
end
