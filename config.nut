::flw <- fe.layout.width;
::flh <- fe.layout.height;

::config <- {
  containerParent = {
		x = (flw - matchAspect(4, 3, "height", flh)) / 2,
		y = 0,
		width = matchAspect(4, 3, "height", flh),
		height = flh,
	},
	container = {
		x = 0,
		y = 0,
		width = matchAspect(4, 3, "height", flh),
		height = flh,
	},
};

config.video <- {
	x = 0,
	y = 0,
	width = config.container.width,
	height = config.container.height,
  video_flags = Vid.NoLoop,
};
