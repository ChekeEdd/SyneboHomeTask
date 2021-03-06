public class searchCasesController {
    
    public class searchCasesException extends Exception{                
    }
    
    @AuraEnabled
    public static ResponseWrapper findCase(String KeyWord, String typeField, Integer recordsPerPage, Integer pageNumber) {
        
        Integer offset = ( pageNumber - 1) * recordsPerPage;
        
        String searchKey; //= '%' + KeyWord + '%';
        if(!String.isBlank(KeyWord)){
            searchKey =  '%' + KeyWord + '%';
        } else throw new searchCasesException('Pleas type smth');
        String caseNumber = 'CaseNumber';
        List<String> fields = new List<String>();
        if(caseNumber.equals(typeField)){
            fields.add(caseNumber);            
        }
        else {
            fields.add(caseNumber);
            fields.add(typeField);
        }        
        String query = 'SELECT Id, ' + String.join(fields, ', ') + ' FROM Case WHERE '+ typeField +' LIKE \'' + searchKey +'\' LIMIT ' + recordsPerPage + ' OFFSET ' + offset;
        System.debug('query ' + query);            
        List<Case> caseList = Database.query(query);  
        System.debug(caseList);
        List<Map<String, Object>> listOfMaps = new List<Map<String, Object>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();
        System.debug(fieldMap);
        if(caseNumber.equals(typeField)){
            Schema.DescribeFieldResult dfr = fieldMap.get('CaseNumber').getDescribe();
            Map<String, Object> link = new Map<String, Object>{ 'target' => '_blank', 'label' => new Map<String, String>{'fieldName' => 'CaseNumber'}};
                Map<String, Object> labels = new Map<String, Object>{'fieldName' => 'CaseLink', 'label' => dfr.getLabel() , 'type' => 'url' , 'typeAttributes' => link};
                    listOfMaps.add(labels);
        } 
        else {
            Schema.DescribeFieldResult dfr = fieldMap.get('CaseNumber').getDescribe();
            Map<String, Object> link = new Map<String, Object>{ 'target' => '_blank', 'label' => new Map<String, String>{'fieldName' => 'CaseNumber'}};
            Map<String, Object> labels = new Map<String, Object>{'fieldName' => 'CaseLink', 'label' => dfr.getLabel() , 'type' => 'url' , 'typeAttributes' => link};
            Schema.DescribeFieldResult dfr2 = fieldMap.get(typeField).getDescribe();
            Map<String, Object> labels2 = new Map<String, Object>{'fieldName' => typeField, 'label' => dfr2.getLabel() , 'type' => 'text'};   
            listOfMaps.add(labels);
            listOfMaps.add(labels2);
        }          
        
        ResponseWrapper resp = new ResponseWrapper(listOfMaps, caseList);
        System.debug(resp);
        return resp;
    }
    
    @AuraEnabled
    public static Integer counter(String KeyWord, String typeField, Integer recordsPerPage){
        Integer pages = 0;
        String searchKey = '%' + KeyWord + '%';
        String testquery = 'SELECT count() FROM Case WHERE '+ typeField +' LIKE \'' + searchKey +'\'';
        Integer caseCountList = Database.countQuery(testquery);
        if(math.mod(caseCountList, recordsPerPage) == 0){
            pages = caseCountList / recordsPerPage;
        } else pages = caseCountList / recordsPerPage + 1;
        System.debug(pages);
        return pages;
        
    }
    
   
      
      
    
    public class ResponseWrapper {
        @AuraEnabled
        public List<Case> objects;
        @AuraEnabled
        public List<Map<String, Object>> listOfMaps;
        @AuraEnabled
        public Integer count; 
        
        
        public ResponseWrapper(List<Map<String, Object>> listOfMaps, List<Case> objects) {
            this.listOfMaps = listOfMaps;
            this.objects = objects;            
            
        }
        
    }
}