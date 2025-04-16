import 'package:example/src/dtos/primitive_list_dto.dart';
import 'package:vaden/vaden.dart';

import 'parse_dto.dart';

@Api(tag: 'DTO')
@Controller('/dto')
class DTOController {
  @Post('/parse')
  ParseDto parse(@Body() ParseDto dto) {
    return dto;
  }

  @Post('/primitive_list')
  PrimitiveListDto primitiveList(@Body() PrimitiveListDto dto) {
    return dto;
  }
}

//Test dto
//To parse body
/*
{
  "id":"1",
  "createdAt":"2000-01-01",
  "updatedAt":"2000-02-01"
}
*/
//To primitive_list body
/* 
  {
  "id": "1",
  "numList": [],
  "textList": [],
  "dtoList":[{
    "id": "1",
    "numList": [],
    "textList": [],
    "nullTextList": [],
    "dtoList":[]
  }]
}
*/
