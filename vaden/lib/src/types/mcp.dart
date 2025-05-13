typedef McpToolMap = Map<String, dynamic>;

typedef DtoPropertiesMap = Map<String, dynamic>;

abstract class MCP {
  late final Map<Type, DtoPropertiesMap> _dtoProperties;
  late final List<McpToolMap> _toolList;

  MCP() {
    final maps = getMaps();
    _dtoProperties = maps.$1;
    _toolList = maps.$2;
  }
  (Map<Type, DtoPropertiesMap>, List<McpToolMap>) getMaps();

  Map<String, dynamic>? toProperties(Type dto) {
    final toPropertiesMap = _dtoProperties[dto];
    if (toPropertiesMap == null) {
      return null;
    }
    return toPropertiesMap;
  }

  List<McpToolMap> get toolsMaps => _toolList;

  void addToolMap(McpToolMap toolMap) {
    _toolList.add(toolMap);
  }
}
