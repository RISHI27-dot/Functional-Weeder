defmodule Task4CPhoenixServerWeb.ArenaLive do
  use Task4CPhoenixServerWeb,:live_view
  require Logger

  @doc """
  Mount the Dashboard when this module is called with request
  for the Arena view from the client like browser.
  Subscribe to the "robot:update" topic using Endpoint.
  Subscribe to the "timer:update" topic as PubSub.
  Assign default values to the variables which will be updated
  when new data arrives from the RobotChannel module.
  """
  def mount(_params, _session, socket) do

    Task4CPhoenixServerWeb.Endpoint.subscribe("robot:update")
    :ok = Phoenix.PubSub.subscribe(Task4CPhoenixServer.PubSub, "timer:update")
    # :ok = Phoenix.PubSub.subscribe(Task4CPhoenixServer.PubSub, "robot:position")

    socket = assign(socket, :img_robotA, "robot_facing_north.png")
    socket = assign(socket, :bottom_robotA, 0)
    socket = assign(socket, :left_robotA, 0)
    socket = assign(socket, :robotA_start, "")
    socket = assign(socket, :robotA_goals, [])

    socket = assign(socket, :img_robotB, "robot_facing_south.png")
    socket = assign(socket, :bottom_robotB, 750)
    socket = assign(socket, :left_robotB, 750)
    socket = assign(socket, :robotB_start, "")
    socket = assign(socket, :robotB_goals, [])

    socket = assign(socket, :obstacle_pos, MapSet.new())
    socket = assign(socket, :timer_tick, 300)

    {:ok,socket}

  end

  @doc """
  Render the Grid with the coordinates and robot's location based
  on the "img_robotA" or "img_robotB" variable assigned in the mount/3 function.
  This function will be dynamically called when there is a change
  in the values of any of these variables =>
  "img_robotA", "bottom_robotA", "left_robotA", "robotA_start", "robotA_goals",
  "img_robotB", "bottom_robotB", "left_robotB", "robotB_start", "robotB_goals",
  "obstacle_pos", "timer_tick"
  """
  def render(assigns) do

    ~H"""
    <div id="dashboard-container">

      <div class="grid-container">
        <div id="alphabets">
          <div> A </div>
          <div> B </div>
          <div> C </div>
          <div> D </div>
          <div> E </div>
          <div> F </div>
        </div>

        <div class="board-container">
          <div class="game-board">
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
            <div class="box"></div>
          </div>

          <%= for obs <- @obstacle_pos do %>
            <img  class="obstacles"  src="/images/stone.png" width="50px" style={"bottom: #{elem(obs,1)}px; left: #{elem(obs,0)}px"}>
          <% end %>

          <div class="robot-container" style={"bottom: #{@bottom_robotA}px; left: #{@left_robotA}px"}>
            <img id="robotA" src={"/images/#{@img_robotA}"} style="height:70px;">
          </div>

          <div class="robot-container" style={"bottom: #{@bottom_robotB}px; left: #{@left_robotB}px"}>
            <img id="robotB" src={"/images/#{@img_robotB}"} style="height:70px;">
          </div>

        </div>

        <div id="numbers">
          <div> 1 </div>
          <div> 2 </div>
          <div> 3 </div>
          <div> 4 </div>
          <div> 5 </div>
          <div> 6 </div>
        </div>

      </div>
      <div id="right-container">

        <div class="timer-card">
          <label style="text-transform:uppercase;width:100%;font-weight:bold;text-align:center" >Timer</label>
            <p id="timer" ><%= @timer_tick %></p>
        </div>

        <div class="goal-card">
          <div style="text-transform:uppercase;width:100%;font-weight:bold;text-align:center" > Goal positions </div>
          <div style="display:flex;flex-flow:wrap;width:100%">
            <div style="width:50%">
              <label>Robot A</label>
              <%= for i <- @robotA_goals do %>
                <div><%= i %></div>
              <% end %>
            </div>
            <div  style="width:50%">
              <label>Robot B</label>
              <%= for i <- @robotB_goals do %>
              <div><%= i %></div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="position-card">
          <div style="text-transform:uppercase;width:100%;font-weight:bold;text-align:center"> Start Positions </div>
          <form phx-submit="start_clock" style="width:100%;display:flex;flex-flow:row wrap;">
            <div style="width:100%;padding:10px">
              <label>Robot A</label>
              <input name="robotA_start" style="background-color:white;" value={"#{@robotA_start}"}>
            </div>
            <div style="width:100%; padding:10px">
              <label>Robot B</label>
              <input name="robotB_start" style="background-color:white;" value={"#{@robotB_start}"}>
            </div>

            <button  id="start-btn" type="submit">
              <svg xmlns="http://www.w3.org/2000/svg" style="height:30px;width:30px;margin:auto" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
              </svg>
            </button>

            <button phx-click="stop_clock" id="stop-btn" type="button">
              <svg xmlns="http://www.w3.org/2000/svg" style="height:30px;width:30px;margin:auto" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8 7a1 1 0 00-1 1v4a1 1 0 001 1h4a1 1 0 001-1V8a1 1 0 00-1-1H8z" clip-rule="evenodd" />
              </svg>
            </button>
          </form>
        </div>

      </div>

    </div>
    """

  end

  @doc """
  Handle the event "start_clock" triggered by clicking
  the PLAY button on the dashboard.
  """
  defmodule Position do
    @derive Jason.Encoder
    defstruct x: 1, y: :a, facing: :north
  end
  def handle_event("start_clock", data, socket) do
    socket = assign(socket, :robotA_start, data["robotA_start"])
    socket = assign(socket, :robotB_start, data["robotB_start"])
    # Task4CPhoenixServerWeb.Endpoint.broadcast("timer:start", "start_timer", %{})
    new = String.replace(data["robotA_start"], " ", "")
    str = String.split(new, ",")
    {x_a, ""} = Integer.parse(Enum.at(str, 0))
    y_a = String.to_atom(Enum.at(str, 1))
    facing_a = String.to_atom(Enum.at(str, 2))


    new = String.replace(data["robotB_start"], " ", "")
    str = String.split(new, ",")
    {x_b, ""} = Integer.parse(Enum.at(str, 0))
    y_b = String.to_atom(Enum.at(str, 1))
    facing_b = String.to_atom(Enum.at(str, 2))
    # IO.inspect(data)
    goal_locs = make_goal_loc()
    robot_a_start = %Position{x: x_a, y: y_a, facing: facing_a}
    robot_b_start = %Position{x: x_b, y: y_b, facing: facing_b}
    # robot_b_start = %Position{x: 5, y: :e, facing: :south}
    robot_a_goal_list = []
    robot_b_goal_list = []
    goal_struct_list = []
    {robot_a_goal_list,robot_b_goal_list,goal_locs} =
      while_loop(goal_locs,robot_a_start,robot_b_start,robot_a_goal_list,robot_b_goal_list,goal_struct_list)
      IO.inspect({robot_a_goal_list,robot_b_goal_list})
    data = Map.put(data,"goal_locs_a",robot_a_goal_list)
    data = Map.put(data,"goal_locs_b",robot_b_goal_list)
    Task4CPhoenixServerWeb.Endpoint.broadcast("robot:get_position", "startPos", data)
    # IO.inspect(socket)
    {:noreply, socket}
  end
  ################################################################################################################################
  ################################################################################################################################
  defmodule GoalStruct do
    @derive Jason.Encoder
    defstruct x: 1, y: :a, visited: false, distance_from_a: 0, distance_from_b: 0
  end
  def while_loop(goal_locs,robot_a_start,robot_b_start,robot_a_goal_list,robot_b_goal_list,goal_struct_list) do
    {robot_a_goal_list,robot_b_goal_list,goal_locs} =
    if Enum.empty?(goal_locs) == false do
      {robot_a_goal_list,robot_b_goal_list} =
        divide_goals(goal_locs,robot_a_start,robot_b_start,robot_a_goal_list,robot_b_goal_list,goal_struct_list)
      roba = Enum.at(robot_a_goal_list,0)
      robb = Enum.at(robot_b_goal_list,0)
      goal_locs = rectify(goal_locs,roba,robb)
      while_loop(goal_locs,robot_a_start,robot_b_start,robot_a_goal_list,robot_b_goal_list,goal_struct_list)
    else
      {robot_a_goal_list,robot_b_goal_list,goal_locs}
    end
    {robot_a_goal_list,robot_b_goal_list,goal_locs}
  end
  def rectify(goal_locs, robot_a_goal,robot_b_goal) do
    robota_goal = [to_string(robot_a_goal.x),to_string(robot_a_goal.y)]
    robotb_goal = [to_string(robot_b_goal.x),to_string(robot_b_goal.y)]
    # IO.puts("rectify rectiry")
    # IO.inspect({robota_goal,robotb_goal})
    goal_locs = List.delete(goal_locs,robota_goal)
    goal_locs = List.delete(goal_locs,robotb_goal)

    goal_locs
  end
  def divide_goals(goal_locs,robot_a_start,robot_b_start,robot_a_goal_list, robot_b_goal_list,goal_struct_list) do

    {goal_struct_list,goal_locs} =
      make_goal_struct_list(goal_locs, robot_a_start, robot_b_start, goal_struct_list)
    if Enum.empty?(goal_struct_list) == false do
      # IO.inspect(goal_struct_list)
      goal_list_sorted_acc_to_a = sort_list("a", goal_struct_list)
      robot_a_goal = Enum.at(goal_list_sorted_acc_to_a,0)
      robot_a_goal_list = [robot_a_goal | robot_a_goal_list]
      robot_a_start = %Position{x: robot_a_goal.x, y: robot_a_goal.y, facing: :north}
      List.delete(goal_struct_list,robot_a_goal)
      # IO.inspect(goal_list_sorted_acc_to_a)
      goal_list_sorted_acc_to_b = sort_list("b", goal_struct_list)
      robot_b_goal = Enum.at(goal_list_sorted_acc_to_b,0)
      robot_b_goal_list = [robot_b_goal | robot_b_goal_list]
      robot_b_start = %Position{x: robot_b_goal.x, y: robot_b_goal.y, facing: :north}
      List.delete(goal_struct_list,robot_b_goal)
      goal_struct_list = []
      divide_goals(goal_locs,robot_a_start,robot_b_start,robot_a_goal_list,robot_b_goal_list,goal_struct_list)
    else
      {robot_a_goal_list,robot_b_goal_list}
    end
    # IO.inspect(goal_list_sorted_acc_to_b)
  end
  def make_goal_struct_list(goal_locs, robota, robotb, goal_struct_list) do
    {goal_struct_list,goal_locs} =
      if Enum.empty?(goal_locs) == false do
        x2 = String.to_integer(Enum.at(Enum.at(goal_locs, 0), 0))
        y2 = String.to_atom(Enum.at(Enum.at(goal_locs, 0), 1))

        x1_robota = robota.x
        y1_robota = robota.y

        x1_robotb = robotb.x
        y1_robotb = robotb.y

        dist_form_robota = calculate_dist(x1_robota, y1_robota, x2, y2)
        dist_form_robotb = calculate_dist(x1_robotb, y1_robotb, x2, y2)

        goal = %GoalStruct{
          x: x2,
          y: y2,
          visited: false,
          distance_from_a: dist_form_robota,
          distance_from_b: dist_form_robotb
        }

        goal_struct_list = [goal | goal_struct_list]
        goal_locs = List.delete_at(goal_locs, 0)
        make_goal_struct_list(goal_locs, robota, robotb, goal_struct_list)
      else
        {goal_struct_list,goal_locs}
      end
      # IO.inspect(goal_struct_list)
      {goal_struct_list,goal_locs}
  end

  def calculate_dist(x1, y1, x2, y2) do
    # IO.inspect({x1,y1,x2,y2})
    y_map_atom_to_int = %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5, f: 6}
    y1 = y_map_atom_to_int[y1]
    y2 = y_map_atom_to_int[y2]
    abs(x2 - x1) * abs(x2 - x1) + abs(y2 - y1) * abs(y2 - y1)
  end

  def sort_list(robot, goal_list_struct) do
    if robot == "a" do
      sorted_list =
        Enum.sort(goal_list_struct, fn x, y -> x.distance_from_a < y.distance_from_a end)
    else
      sorted_list =
        Enum.sort(goal_list_struct, fn x, y -> x.distance_from_b < y.distance_from_b end)
    end
  end

  ################################################################################################################################
  ################################################################################################################################
  @doc """
  Handle the event "stop_clock" triggered by clicking
  the STOP button on the dashboard.
  """
  # def handle_event("robot_b_goal", data, socket) do
  #   IO.inspect("handled the goal robot_b_goal event")
  #   socket = assign(socket,:robotB_goals,[data])
  #   {:noreply, socket}
  # end
  def handle_info(%{event: "robot_b_goal", payload: data, topic: "robot:update"}, socket) do
    # IO.inspect("handled the goal robot_b_goal event")
    data_i = socket.assigns.robotB_goals
    data = [data|data_i]
    socket = assign(socket,:robotB_goals,[data])
    {:noreply, socket}
  end
  def handle_info(%{event: "robot_a_goal", payload: data, topic: "robot:update"}, socket) do
    # IO.inspect("handled the goal robot_b_goal event")
    data_i = socket.assigns.robotA_goals
    data = [data|data_i]
    socket = assign(socket,:robotA_goals,[data])
    {:noreply, socket}
  end

  def handle_event("stop_clock", _data, socket) do

    Task4CPhoenixServerWeb.Endpoint.broadcast("timer:stop", "stop_timer", %{})

    #################################
    ## edit the function if needed ##
    #################################

    {:noreply, socket}

  end

  @doc """
  Callback function to handle incoming data from the Timer module
  broadcasted on the "timer:update" topic.
  Assign the value to variable "timer_tick" for each countdown.
  """
  def handle_info(%{event: "update_timer_tick", payload: timer_data, topic: "timer:update"}, socket) do

    Logger.info("Timer tick: #{timer_data.time}")
    socket = assign(socket, :timer_tick, timer_data.time)

    {:noreply, socket}

  end

  @doc """
  Callback function to handle any incoming data from the RobotChannel module
  broadcasted on the "robot:update" topic.
  Assign the values to the variables => "img_robotA", "bottom_robotA", "left_robotA",
  "img_robotB", "bottom_robotB", "left_robotB" and "obstacle_pos" as received.
  Make sure to add a tuple of format: { < obstacle_x >, < obstacle_y > } to the MapSet object "obstacle_pos".
  These values msut be in pixels. You may handle these variables in separate callback functions as well.
  """
  def handle_info(data, socket) do
    # data = data.payload
    # IO.inspect("handle_info called in arena live")
    # IO.puts("############################################################################################################")
    # IO.inspect(data)
    # IO.puts("############################################################################################################")
    socket =
    if (data["client"] == "robot_A") do
      socket =
      cond do
        (data["face"] == "north")->
          socket = assign(socket, :img_robotA, "robot_facing_north.png")
        (data["face"]  == "south")->
          socket = assign(socket, :img_robotA, "robot_facing_south.png")
        (data["face"] == "east")->
          socket = assign(socket, :img_robotA, "robot_facing_east.png")
        (data["face"] == "west")->
          socket = assign(socket, :img_robotA, "robot_facing_west.png")
      end
      socket = assign(socket, :bottom_robotA, data["bottom"])
      socket = assign(socket, :left_robotA, data["left"])
    else
      socket
    end
    socket =
    if (data["client"] == "robot_B") do
      socket =
      cond do
        (data["face"] == "north")->
          socket = assign(socket, :img_robotB, "robot_facing_north.png")
        (data["face"]  == "south")->
          socket = assign(socket, :img_robotB, "robot_facing_south.png")
        (data["face"] == "east")->
          socket = assign(socket, :img_robotB, "robot_facing_east.png")
        (data["face"] == "west")->
          socket = assign(socket, :img_robotB, "robot_facing_west.png")
      end
      socket = assign(socket, :bottom_robotB, data["bottom"])
      socket = assign(socket, :left_robotB, data["left"])
    else
      socket
    end
    socket =
      if data["obs"] == true do
        {left_data, bottom_data} = find_obs_pixels(data["face"],data["left"],data["bottom"])
        map_set_old = socket.assigns.obstacle_pos
        socket = assign(socket,:obstacle_pos,MapSet.put(map_set_old,{left_data,bottom_data}))
      else
        socket
      end

    # socket = assign(socket,:img_robotB, "robot_facing_east.png")
    # IO.inspect(socket)
    # socket = assign(socket, :robotA_goals, [])
    # socket = assign(socket, :robotB_goals, [])
    # socket = assign(socket, :obstacle_pos, MapSet.new())
    {:noreply, socket}
  end
  def find_obs_pixels(face,left, bottom) do
    {left_ret, bottom_ret} =
      cond do
        face == "east" ->
          left_ret = left + 75
          bottom_ret = bottom
          {left_ret, bottom_ret}
        face == "west" ->
          left_ret = left - 75
          bottom_ret = bottom
          {left_ret, bottom_ret}
        face == "north" ->
          left_ret = left
          bottom_ret = bottom + 75
          {left_ret, bottom_ret}
        face == "south" ->
          left_ret = left
          bottom_ret = bottom - 75
          {left_ret, bottom_ret}
      end
  end
  def make_goal_loc do
    csv =
      "~/Desktop/Functional-Weeder/task_4c_communication_two_robots/task_4c_phoenix_server/Plant_Positions.csv"
      |> Path.expand(__DIR__)
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.map(fn data -> data end)
    list_of_goals = []
    goal_locs = make_list(csv,list_of_goals)
    # IO.inspect(goal_locs)
  end

  def make_list(csv,list_of_goals) do
    list_ret =
    if(Enum.empty?(csv)) do
      list_of_goals
    else
      map = Kernel.elem(Enum.at(csv,0),1)
      n1 = Map.get(map,"Sowing")
      n2 = Map.get(map,"Weeding")
      # list_of_goals = list_of_goals ++ get_goal(n1)
      # list_of_goals = list_of_goals ++ [List.to_tuple(get_goal(n1))]
      list_of_goals = list_of_goals ++ [get_goal(n1)]
      # IO.inspect(list_of_goals)
      # IO.inspect(get_goal(n1))
      # list_of_goals = list_of_goals ++ [List.to_tuple(get_goal(n2))]
      list_of_goals = list_of_goals ++ [get_goal(n2)]
      # list_of_goals = list_of_goals ++ get_goal(n2)
      # IO.inspect(list_of_goals)
      # IO.inspect(get_goal(n2))
      csv = List.delete_at(csv,0)
      make_list(csv,list_of_goals)
    end
    list_ret
  end
  def get_goal(n) do
    map = %{1 =>"a", 2 => "b", 3 => "c", 4 => "d", 5 => "e" , 6 => "f"}
    n = String.to_integer(n)
    list =
    cond do
      n>= 1 and n<=5 ->
        x1 =to_string(n)
        # x2 =to_string(n+1)
        y1 =map[1]
        # y2 = map[2]
        #IO.puts "#{x1},#{x2},#{y1},#{y2}"
        # lst = [x1,y1,x1,y2,x2,y1,x2,y2]
        lst = [x1,y1]
      n>=6 and n<=10 ->
        x1 =to_string(n-5)
        # x2 =to_string(n-5+1)
        y1 =map[2]
        # y2 = map[3]
        # lst = [x1,y1,x1,y2,x2,y1,x2,y2]
        lst = [x1,y1]
      n>=11 and n<=15 ->
        x1 =to_string(n-10)
        # x2 =to_string(n-10+1)
        y1 =map[3]
        # y2 = map[4]
        # lst = [x1,y1,x1,y2,x2,y1,x2,y2]
        lst = [x1,y1]
      n>=16 and n<=20 ->
        x1 =to_string(n-15)
        # x2 =to_string(n-15+1)
        y1 =map[4]
        # y2 = map[5]
        lst = [x1,y1]
        # lst = [x1,y1,x1,y2,x2,y1,x2,y2]
      n>=21 and n<=25 ->
        x1 =to_string(n-20)
        # x2 =to_string(n-20+1)
        y1 = map[5]
        # y2 = map[6]
        # lst = [x1,y1,x1,y2,x2,y1,x2,y2]
        lst = [x1,y1]
    end
    list
  end
  ######################################################
  ## You may create extra helper functions as needed  ##
  ## and update remaining assign variables.           ##
  ######################################################

end
