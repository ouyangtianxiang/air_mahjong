-- 更新区域的问题                                   **没size的话更新全屏 大小不好获得
-- particleSystem位置不对 & 第一帧和刷新的位置不对   **改 particleSystem 本身的顶点位置 + imgsize
-- particleSystem forevertype 渲染不出              **paticleSystem self.m_isPaused 错误 

drawingTable = {}

drawing_create_image2 = drawing_create_image;
anim_set_event2 = anim_set_event;
drawing_set_touchable2 = drawing_set_touchable;
drawing_set_dragable2 = drawing_set_dragable;

res_create_double_array2 = res_create_double_array;
res_create_int_array2 = res_create_int_array;
res_create_ushort_array2 = res_create_ushort_array;
res_set_double_array2 = res_set_double_array;
res_set_int_array2 = res_set_int_array;
res_set_ushort_array2 = res_set_ushort_array;

kRenderPoints = gl.GL_POINTS
kRenderLines = gl.GL_LINES
kRenderLineLoop = gl.GL_LINE_LOOP
kRenderLineStrip = gl.GL_LINE_STRIP
kRenderTriangles = gl.GL_TRIANGLES
kRenderTriangleStrip = gl.GL_TRIANGLE_STRIP
kRenderTriangleFan = gl.GL_TRIANGLE_FAN

kResTypeFloatArray = 61
kResTypeIntArray = 63
kResTypeUshortArray = 65

local function getResData(buffer,dataType)
    local dataTypeChar = nil;

    if dataType == kResTypeFloatArray then
        dataTypeChar = "f"
    elseif dataType == kResTypeIntArray then
        dataTypeChar = "In"
    elseif dataType == kResTypeUshortArray then
        dataTypeChar = "H"
    end

    local length = string.len(buffer)
    local size = struct.size(dataTypeChar)

    local resTable = {}
    local pos = 1         
    for i = 1,length/size do
      local f
      f, pos = struct.unpack(dataTypeChar, buffer, pos)
      resTable[i] = f
      i = i + 1
    end

    return resTable
end


local function initWidget(drawingId,renderType)
    local drawing = {}

    drawingTable[drawingId] = drawing
    
    drawing.drawingId = drawingId
    
    local pos = drawing_get_position(drawing.drawingId)

    local size = drawing_get_size(drawing.drawingId)

    drawing.updateScreen = 0

    if size[1] == 0 or size[2] == 0 then
        size[1] = System:getScreenWidth()
        size[2] = System:getScreenHeight()
        drawing.updateScreen = 1
    end

    drawing.widget = LuaWidget()

    drawing.widget.pos = Point(unpack(pos))

    drawing.widget.size = Point(unpack(size))

    drawing.widget.relative = true

    local oriWidget = Widget.get_by_id(drawing.drawingId)

    if oriWidget.parent then
        oriWidget.parent:add(drawing.widget,oriWidget)

        for i = 1, #oriWidget.children do
            drawing.widget:add(oriWidget.children[i])
        end  
    end

    oriWidget:cleanup()

    drawing.widget:setId(drawing.drawingId) 

    drawing.vertex   = {}
    drawing.index    = {}
    drawing.texcoord = {}
    drawing.color = {}
    drawing.textureUnit = TextureUnit.default_unit()


    drawing.widget.on_cleanup = function (self)
        drawingTable[drawing.widget:getId()] = nil
    end

    --[[drawing.widget.on_color_changed = function (self)
        
        print(drawing.widget.display_color.r,
              drawing.widget.display_color.g,
              drawing.widget.display_color.b,
              drawing.widget.display_color.a,
              "color changed---------------------------")
        for i = 1 ,#drawing.color/4 do
             
             drawing.color[(i - 1) * 4 +1] = drawing.color[(i - 1) * 4 +1] * drawing.widget.display_color.r
             drawing.color[(i - 1) * 4 +2] = drawing.color[(i - 1) * 4 +2] * drawing.widget.display_color.g
             drawing.color[(i - 1) * 4 +3] = drawing.color[(i - 1) * 4 +3] * drawing.widget.display_color.b
             drawing.color[(i - 1) * 4 +4] = drawing.color[(i - 1) * 4 +4] * drawing.widget.display_color.a
        end
        
    end]]

    drawing.widget.lua_do_draw = function (self,canvas)
        
        if self.dirty == true then
            drawing.g = LuaVertexBuilder(VBO.default_format_id(),renderType or kRenderTriangleStrip,function ()
                local vertex = {}
                local index = drawing.index

                if #drawing.color == 0 then
                    for i = 1 ,#drawing.vertex/2 do
                        drawing.color[(i - 1) * 4 +1] = 1 
                        drawing.color[(i - 1) * 4 +2] = 1 
                        drawing.color[(i - 1) * 4 +3] = 1 
                        drawing.color[(i - 1) * 4 +4] = 1 
                    end
                elseif #drawing.color/4 < #drawing.vertex/2 then
                    for i = #drawing.color/4 + 1 ,#drawing.vertex/2 do
                        drawing.color[(i - 1) * 4 +1] = 1 
                        drawing.color[(i - 1) * 4 +2] = 1 
                        drawing.color[(i - 1) * 4 +3] = 1 
                        drawing.color[(i - 1) * 4 +4] = 1 
                    end
                end
                
                for i = 1 ,#drawing.vertex/2 do
                    table.insert(vertex,struct.pack("ffffffffffffff",drawing.vertex[(i - 1) * 2 + 1],
                                                                     drawing.vertex[(i - 1) * 2 + 2], 
                                                                     0,
                                                                         drawing.texcoord[(i - 1) * 2 + 1],
                                                                         drawing.texcoord[(i - 1) * 2 + 2],
                                                                         1,
                                                                             drawing.color[(i - 1) * 4 +1] * drawing.widget.display_color.r,
                                                                             drawing.color[(i - 1) * 4 +2] * drawing.widget.display_color.g,
                                                                             drawing.color[(i - 1) * 4 +3] * drawing.widget.display_color.b,
                                                                             drawing.color[(i - 1) * 4 +4] * drawing.widget.display_color.a,
                                                                                 0,0,0,0))
                end  
                return vertex,index
            end)  
        end     

        canvas:add(BindTexture(drawing.textureUnit.texture,0))
        canvas:add(drawing.g)
    end
end


function drawing_set_node_renderable(iDrawingId,renderType,__)
    if drawingTable[iDrawingId] == nil then
        initWidget(iDrawingId,renderType)  --switch renderType
    end
end

function drawing_set_node_texture(iDrawingId,iResIdBitmap, iResDoubleArrayIdTextureCoord )
    if drawingTable[iDrawingId] == nil then
        initWidget(iDrawingId,kRenderTriangles)         
    end

    drawingTable[iDrawingId].textureUnit = TextureUnit.get_by_id(iResIdBitmap)

    res_listen_buffer(iResDoubleArrayIdTextureCoord, kResTypeFloatArray, function(buf)
        local t = getResData(buf,kResTypeFloatArray)
        drawingTable[iDrawingId].texcoord = t
        if drawingTable[iDrawingId].updateScreen == 0 then
            drawingTable[iDrawingId].widget:invalidate()
        else 
            Window.instance().drawing_root:invalidate()
        end
    end)
end

function drawing_set_node_vertex(iDrawingId,iResDoubleArrayIdVertex,iResUShortIdIndices )
    if drawingTable[iDrawingId] == nil then  
        initWidget(iDrawingId,kRenderTriangles)
    end

    res_listen_buffer(iResDoubleArrayIdVertex, kResTypeFloatArray, function(buf)
        local t = getResData(buf,kResTypeFloatArray)
        drawingTable[iDrawingId].vertex = t
        if drawingTable[iDrawingId].updateScreen == 0 then
            drawingTable[iDrawingId].widget:invalidate()
        else 
            Window.instance().drawing_root:invalidate()
        end
    end)

    res_listen_buffer(iResUShortIdIndices, kResTypeUshortArray, function(buf)
        local t = getResData(buf,kResTypeUshortArray)
        drawingTable[iDrawingId].index = t
        if drawingTable[iDrawingId].updateScreen == 0 then
            drawingTable[iDrawingId].widget:invalidate()
        else 
            Window.instance().drawing_root:invalidate()
        end
    end)
end

function drawing_set_node_colors(iDrawingId,iResDoubleArrayIdColors )
	local drawing = drawingTable[iDrawingId]
    
    if drawing.widget == nil then
        initWidget(iDrawingId,kRenderTriangles)
    end

    res_listen_buffer(iResDoubleArrayIdColors, kResTypeFloatArray, function(buf)
        local t = getResData(buf,kResTypeFloatArray)
        drawingTable[iDrawingId].color = t
        if drawingTable[iDrawingId].updateScreen == 0 then
            drawingTable[iDrawingId].widget:invalidate()
        else 
            Window.instance().drawing_root:invalidate()
        end
    end)
end