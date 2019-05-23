----------------------------------------------------------------------
-- A slice tool script
-- Autohr: Shitake
----------------------------------------------------------------------
local TYPE_AUTO = "Automatic"
local TYPE_BY_SIZE = "Grid by Cell Size"
local TYPE_BY_COUNT = "Grid by Cell Count"
local METHOD_SMALL = "Small"
local METHOD_SAFE = "Safe"

local sprite = app.activeSprite

local dlg_conf = Dialog("Slice Sprite Type")
dlg_conf
  :combobox{  id="type",
              label="Type",
              option=TYPE_BY_SIZE,
              options={ TYPE_BY_SIZE, TYPE_BY_COUNT }}
              -- TODO: wait support
              -- options={ TYPE_AUTO, TYPE_BY_SIZE, TYPE_BY_COUNT } }
  :check{ id="clear", text="Clear old slice", selected=true }
  :color{ id="color", color=Color{ r=255, g=255, b=255, a=180 } }
  :button{ id="ok", text="&OK", focus=true }
  :button{ text="&Cancel" }

local dlg_slice_by_auto_data = Dialog("Auto Slice method")
dlg_slice_by_auto_data
  :combobox{  id="method",
              label="Method",
              option=METHOD_SMALL,
              options={ METHOD_SMALL, METHOD_SAFE } }
  :separator{ label="Pivot", text="Pivot" }
  :number{ id="pivot_x", label="X:", text="0", decimals=integer }
  :number{ id="pivot_y", label="Y:", text="0", decimals=integer }
  :button{ id="ok", text="&OK", focus=true }
  :button{ id="back", text="&Back" }

local dlg_slice_by_size_data = Dialog("Slice Data(Size)")
dlg_slice_by_size_data
  :separator{ label="Cell Size", text="Cell Size" }
  :number{ id="width", label="Width:", text="8", decimals=integer }
  :number{ id="height", label="Height:", text="8", decimals=integer }
  :separator{ label="Padding", text="Padding" }
  :number{ id="padding_x", label="X:", text="0", decimals=integer }
  :number{ id="padding_y", label="Y:", text="0", decimals=integer }
  :separator{ label="Pivot", text="Pivot" }
  :number{ id="pivot_x", label="X:", text="0", decimals=integer }
  :number{ id="pivot_y", label="Y:", text="0", decimals=integer }
  :button{ id="ok", text="&OK", focus=true }
  :button{ id="back", text="&Back" }

local dlg_slice_by_count_data = Dialog("Slice Data(Count)")
dlg_slice_by_count_data
    :number{ id="column", label="Column:", text="1", decimals=integer }
    :number{ id="row", label="Row:", text="1", decimals=integer }
    :separator{ label="Padding", text="Padding" }
    :number{ id="padding_x", label="X:", text="0", decimals=integer }
    :number{ id="padding_y", label="Y:", text="0", decimals=integer }
    :separator{ label="Pivot", text="Pivot" }
    :number{ id="pivot_x", label="X:", text="0", decimals=integer }
    :number{ id="pivot_y", label="Y:", text="0", decimals=integer }
    :button{ id="ok", text="&OK", focus=true }
    :button{ id="back", text="&Back" }

function slice_by_auto_show()
  dlg_slice_by_auto_data:show()
  if dlg_slice_by_auto_data.data.ok then 
    slice_by_auto()
  end
  if dlg_slice_by_auto_data.data.back then main() end
end

function slice_by_size_show()
  dlg_slice_by_size_data:show()
  if dlg_slice_by_size_data.data.ok then 
    slice_by_size()
  end
  if dlg_slice_by_size_data.data.back then main() end
end

function slice_by_count_show()
  dlg_slice_by_count_data:show()
  if dlg_slice_by_count_data.data.ok then 
    slice_by_count()
  end
  if dlg_slice_by_count_data.data.back then main() end
end

function slice_by_auto()
  clear_slice()
  data = dlg_slice_by_count_data.data
end

function slice_by_size()
  clear_slice()
  data = dlg_slice_by_size_data.data
  cell_width = data.width
  cell_height = data.height
  index = 0
  column = 0
  while column * cell_width < sprite.width do
    row = 0
    while row * cell_height < sprite.height do
      slice = sprite:newSlice(Rectangle(
        column  * cell_width + data.padding_x, 
        row * cell_height + data.padding_y, 
        cell_width - data.padding_x * 2, 
        cell_height - data.padding_y * 2))
      slice.color =  dlg_conf.data.color
      slice.name = sprite.filename .. "_" .. index
      slice.pivot = Point(data.pivot_x, data.pivot_y)
      index = index + 1
      row = row + 1
    end
    column = column + 1
  end
end

function slice_by_count()
  clear_slice()
  data = dlg_slice_by_count_data.data
  cell_width = math.floor(sprite.width / data.column)
  cell_height = math.floor(sprite.height / data.row)
  index = 0
  for column = 0, data.column - 1 do
    for row = 0, data.row - 1 do
      slice = sprite:newSlice(Rectangle(
        column * cell_width + data.padding_x, 
        row * cell_height + data.padding_y, 
        cell_width - data.padding_x * 2, 
        cell_height - data.padding_y * 2))
      slice.color =  dlg_conf.data.color
      slice.name = sprite.filename .. "_" .. index
      slice.pivot = Point(data.pivot_x, data.pivot_y)
      index = index + 1
    end
  end
end

function clear_slice()
  if not dlg_conf.data.clear then return end
  for i, s in ipairs(sprite.slices) do
    sprite:deleteSlice(s)
  end
end

function main()
  dlg_conf:show()
  if not dlg_conf.data.ok then return end
  if dlg_conf.data.type == TYPE_AUTO then slice_by_auto_show() end
  if dlg_conf.data.type == TYPE_BY_SIZE then slice_by_size_show() end
  if dlg_conf.data.type == TYPE_BY_COUNT then slice_by_count_show() end
end

main()