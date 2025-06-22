/// Abstract class for parameter parsing and serialization in Vaden.
///
/// The `ParamParse` interface defines a contract for converting between 
/// parameter types and JSON-serializable types in the Vaden framework.
/// Implementations of this interface can be used with the `@UseParse` 
/// annotation to customize how request parameters are parsed and how 
/// response values are serialized.
///
/// Type parameters:
/// - `P`: The parameter type (the dart type used in your code)
/// - `R`: The representation type (typically a JSON-serializable type)
///
/// Example:
/// ```dart
/// class DateTimeParser extends ParamParse<DateTime, String> {
///   const DateTimeParser();
///
///   @override
///   String toJson(DateTime param) => param.toIso8601String();
///
///   @override
///   DateTime fromJson(String json) => DateTime.parse(json);
/// }
///
/// @Controller('/api/events')
/// class EventController {
///   @Get('/')
///   Future<Response> getEvents(
///     Request request,
///     @Query('start') @UseParse(DateTimeParser) DateTime startDate,
///   ) {
///     // startDate is automatically parsed from the query parameter
///     // using the DateTimeParser
///     return Response.ok('Events after $startDate');
///   }
/// }
/// ```
abstract class ParamParse<P, R> {
  /// Creates a ParamParse instance.
  const ParamParse();

  /// Converts a parameter of type P to its JSON-serializable representation of type R.
  ///
  /// This method is used when serializing outgoing data, such as in response bodies.
  ///
  /// [param] - The parameter value to convert to its JSON-serializable representation.
  /// Returns the JSON-serializable representation of the parameter.
  R toJson(P param);

  /// Converts a JSON-serializable value of type R to its parameter type P.
  ///
  /// This method is used when deserializing incoming data, such as from request bodies,
  /// query parameters, or path parameters.
  ///
  /// [json] - The JSON-serializable value to convert to the parameter type.
  /// Returns the parameter value parsed from the JSON-serializable representation.
  P fromJson(R json);
}