// ---------- RANTRO INTRO ----------

// --------------------
// Load Modules
// --------------------

fe.load_module("helpers");
fe.load_module("file");
fe.load_module("shader");

// --------------------
// Layout User Options
// --------------------

local userConfig = {
	order = 0,
	prefix = "---------- ",
	postfix = " ----------",
}

class UserConfig {
  </ label=userConfig.prefix + "GENERAL" + userConfig.postfix,
    help="mvscomplete intro",
    order=userConfig.order++ />
  general="";

    </ label="Intro Video",
      help="Toggle playback of intro video when Attract-Mode starts",
      options="On, Off",
      order=userConfig.order++ />
    intro="On";

    </ label="Video Path",
      help="Video to play at startup. Use folder path only to select a random video.",
      order=userConfig.order++ />
    video="4x3/";

		</ label="Force 4:3 aspect",
      help="Force video to play in 4:3 aspect ratio.",
			options="Yes, No",
      order=userConfig.order++ />
    force="No";

  </ label=userConfig.prefix + "SHADERS" + userConfig.postfix,
		order=userConfig.order++ />
	shaders="";

		</ label="CRT Shader",
			help="CRT Shader applied.",
			options="Disabled, Crt Cgwg, Crt Lottes",
			order=userConfig.order++ />
		crtShader="Disabled";

		</ label="Enable Bloom Shader",
			help="Bloom applied with CRT shaders.",
			options="Yes, No",
			order=userConfig.order++ />
		bloom="No";
}
local userConfig = fe.get_config();

// --------------------
// Config
// --------------------

local flw = fe.layout.width;
local flh = fe.layout.height;

local config = {
  containerParent = {
		x = 0,
		y = 0,
		width = flw,
		height = flh,
	},
	container = {
		x = 0,
		y = 0,
		width = flw,
		height = flh,
	},
};

if (toBool(userConfig["force"])) {
	config.containerParent.x = (flw - matchAspect(4, 3, "height", flh)) / 2;
	config.containerParent.width = matchAspect(4, 3, "height", flh);
	config.container.width = matchAspect(4, 3, "height", flh);
}

config.video <- {
	x = 0,
	y = 0,
	width = config.container.width,
	height = config.container.height,
  video_flags = Vid.NoLoop,
};

// --------------------
// Layout
// --------------------

// ---------- End Mode

function end_mode() {
  fe.signal("select");
}

// End mode if intro is off
if (toBool(userConfig["intro"]) != true) end_mode();

// ---------- Container

local containerParent = fe.add_surface(config.containerParent.width, config.containerParent.height);
	setProps(containerParent, config.containerParent);

local container = containerParent.add_surface(config.container.width, config.container.height);
	setProps(container, config.container);

// ---------- Video

local videoPath = null;

// Expand path if relative
if (fe.path_test(userConfig["video"], PathTest.IsRelativePath)) {
	userConfig["video"] = fe.script_dir + userConfig["video"];
}

// Set video path if is file and is supported media
if (fe.path_test(userConfig["video"], PathTest.IsFile) && fe.path_test(userConfig["video"], PathTest.IsSupportedMedia)) {
	videoPath = userConfig["video"];
}

// Set video path to random video if is directory
if (fe.path_test(userConfig["video"], PathTest.IsDirectory)) {
	// Create video list
	local videoList = [];

	// Create directory listing
	local dir = DirectoryListing(userConfig["video"], true);

	// Add path to video list if is file and is supported media
	for (local i=0; i<dir.results.len(); i++) {
		if (fe.path_test(dir.results[i], PathTest.IsFile) && fe.path_test(dir.results[i], PathTest.IsSupportedMedia)) {
			videoList.push(dir.results[i]);
		}
	}

	// Set video path to random video
	if (videoList.len() > 0) videoPath = videoList[randInt(videoList.len()-1)];
}

if (videoPath == null) {
	printL("Randtro: video path is invalid. Skipping intro.");
	end_mode();
}

local video = container.add_image(videoPath, -1, -1, 1, 1);
  setProps(video, config.video);

fe.add_ticks_callback("intro_tick");
function intro_tick(ttime) {
  if (video.video_playing == false) end_mode();
  return false;
}

// --------------------
// Shaders
// --------------------

local shaderCrtLottes = CrtLottes();
local shaderCrtCgwg = CrtCgwg();
local shaderBloom = Bloom();

switch (userConfig["crtShader"]){
	case "Crt Lottes":
		if (toBool(userConfig["bloom"])) containerParent.shader = shaderBloom.shader;
		container.shader = shaderCrtLottes.shader;
		break;
	case "Crt Cgwg":
		if (toBool(userConfig["bloom"])) containerParent.shader = shaderBloom.shader;
		container.shader = shaderCrtCgwg.shader;
		break;
	default:
		containerParent.shader = fe.add_shader(Shader.Empty);
		container.shader = fe.add_shader(Shader.Empty);
		break;
}
