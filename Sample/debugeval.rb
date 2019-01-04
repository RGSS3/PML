Debug.eval(%{
    require 'net/http'
    Net::HTTP.get URI "https://rpg.blue"
}) do |x|
    msgbox x
end
loop do
    break if Input.press?(Input::B)
    Graphics.update
    Input.update
end