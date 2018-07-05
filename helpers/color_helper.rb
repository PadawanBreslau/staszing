module ColorHelper
  def green(diff=0)
    "#00#{[(180 - diff), 50].max.to_s(16)}00"
  end

  def red(diff=0)
    "##{[(255 - diff), 80].max.to_s(16)}0000"
  end

  def purple(diff=0)
    "##{(90 - diff).to_s(16)}00#{(90-diff).to_s(16)}"
  end

  def blue(diff=0)
    "#0000#{(90-diff).to_s(16)}"
  end
end
