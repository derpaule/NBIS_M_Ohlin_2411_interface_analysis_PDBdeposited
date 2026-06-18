# Canonical loader for project-wide PyMOL settings.
# Keep the actual generated settings in PyMol/pymol_settings.py.
from pathlib import Path

from pymol import cmd


def _resolve_settings_path():
	try:
		root = Path(__file__).resolve().parent
	except NameError:
		root = Path.cwd()
	return root / "PyMol" / "pymol_settings.py"


settings_path = _resolve_settings_path()
if not settings_path.exists():
	raise FileNotFoundError(f"PyMOL settings file not found: {settings_path}")

cmd.do(f'run "{settings_path.as_posix()}"')
