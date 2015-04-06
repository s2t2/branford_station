module TwitterBootstrapHelper
  def bootstrap_label_class(value)
    case value
    when true
      "success"
    when false
      "danger"
    else
      "default"
    end
  end
end
