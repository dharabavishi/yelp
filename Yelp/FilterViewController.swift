//
//  FilterViewController.swift
//  Yelp
//
//  Created by Ruchit Mehta on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
@objc protocol FilterViewControllerDeleagte {
    
    @objc optional func filterViewController(_ filterViewController: FilterViewController, didUpdateFilters filter: FilterData)
    
}
class FilterViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var switchStatus : [IndexPath:Bool] = [:]
    var isOpenStaus = [false,false,false,false]
    var objFilterData = FilterData()
    
    @IBOutlet weak var filterTableView: UITableView!
    weak var delegate: FilterViewControllerDeleagte?
    let defaultSwithcStates = "SwitchStates"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Filter"
        loadSavedData()
       
    }
    
    //MARK: Save data
    func loadSavedData() {
        let defaults = UserDefaults.standard
        if let switchStates = defaults.object(forKey: defaultSwithcStates){
            let switchStatesData = NSKeyedUnarchiver.unarchiveObject(with: switchStates as! Data) as? [IndexPath: Bool]
            self.switchStatus = switchStatesData!
        } else {
            self.switchStatus = [IndexPath:Bool]()
        }
        defaults.synchronize()
    }
    
    func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: switchStatus) , forKey: defaultSwithcStates)
        defaults.synchronize()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        
        return getSectionName(sectionNumer: section)
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {

        
        return isOpenStaus.count
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return getRowCounts(sectionNumber: section)
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch sectionsFilter(rawValue: indexPath.section)! {
        case .deals:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            cell.titleLabel.text = getArrayOnBasisOfSection(section: indexPath.section)[indexPath.row]
            cell.dealSwitch.isOn = switchStatus[indexPath] ?? false
            cell.selectionStyle = .none
            return cell
            
        case .sort,.distance:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandCell", for: indexPath) as! ExpandCell
            if( isOpenStaus[indexPath.section]){
                cell.radioButton.isHidden = false
                cell.expnadButton.isHidden = true
                if(switchStatus[indexPath] != nil){
                    
                    if(switchStatus[indexPath])!{
                        cell.radioButton.isSelected = true
                    }
                    else{
                        cell.radioButton.isSelected = false
                    }
                }
                else{
                    cell.radioButton.isSelected = false
                }
                cell.titleLabel.text = getArrayOnBasisOfSection(section: indexPath.section)[indexPath.row]

                
            }
            else{
                cell.radioButton.isHidden = true
                cell.expnadButton.isHidden = false
                let selectedRow = getSelectedRowForOpening(indexPath: indexPath)
                print("selectd row \(selectedRow)")
                print("selected value is here \(getArrayOnBasisOfSection(section: indexPath.section)[selectedRow])")
                cell.titleLabel.text = getArrayOnBasisOfSection(section: indexPath.section)[selectedRow]
            }
           
            
            return cell
            
        case .category:
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
           
            cell.selectionStyle = .none
            if(!isOpenStaus[indexPath.section] && indexPath.row==3){
                cell.viewAllButton.isHidden = false
                cell.titleLabel.isHidden = true
                cell.dealSwitch.isHidden = true
            }
            else{
                cell.viewAllButton.isHidden = true
                cell.titleLabel.isHidden = false
                cell.dealSwitch.isHidden = false
                cell.titleLabel.text = FilterViewController.categories[indexPath.row]["name"]
                cell.dealSwitch.isOn = switchStatus[indexPath] ?? false
            }
            
            return cell

            

        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sectionsFilter(rawValue: indexPath.section)! {
        case .sort,.distance:
            
            if(!isOpenStaus[indexPath.section])
            {
                isOpenStaus[indexPath.section] = !isOpenStaus[indexPath.section]
                self.filterTableView.reloadData()
            }
            else
            {
                expandContractCell(indexPath: indexPath)
            }
            
            
            
            
         default: break
            
            
        }
    }
   
    
    

   //MARK : IBACtions
    @IBAction func onSearchFilter(_ sender: AnyObject) {
        
        
        objFilterData.deal = getSelectedDeal()
        objFilterData.sort = getSelectedSort()
        objFilterData.radius = getSelectedRadius()
        objFilterData.categories = getSelectedCategories()
        
        print(objFilterData.deal)
        print(objFilterData.sort)
        print(objFilterData.radius)
        print(objFilterData.categories)
        saveData()
        delegate?.filterViewController?(self, didUpdateFilters: objFilterData)
        self.dismiss(animated: true) { () -> Void in
            // Do nothing
        }

    }
    
   
    @IBAction func onCancelFilter(_ sender: AnyObject) {
        self.dismiss(animated: true) { () -> Void in
            // Do nothing
        }
    }
    @IBAction func onSeeAllClick(_ sender: UIButton) {
        
        let indexPath = filterTableView.indexPath(for: sender.superview?.superview as! UITableViewCell)!
        isOpenStaus[indexPath.section] =  !isOpenStaus[indexPath.section]
        self.filterTableView.reloadData()
    }
    
    @IBAction func dealChanged(_ sender: UISwitch) {
        
        let indexPath = filterTableView.indexPath(for: sender.superview?.superview as! UITableViewCell)!
        switchStatus[indexPath] = sender.isOn
        self.filterTableView.reloadData()
    }
    @IBAction func onCellExpandButtonClick(_ sender: UIButton) {
        
        let indexPath = filterTableView.indexPath(for: sender.superview?.superview as! UITableViewCell)!
        isOpenStaus[indexPath.section] = !isOpenStaus[indexPath.section]
        self.filterTableView.reloadData()
        
    }
    
    @IBAction func onSelectButton(_ sender: UIButton) {
        let indexPath = filterTableView.indexPath(for: sender.superview?.superview as! UITableViewCell)!
        
        expandContractCell(indexPath: indexPath)
        
    }
    //MARK : Helper functions
    func getArrayOnBasisOfSection(section:Int)->Array<String>{
        let newSec = section
        switch sectionsFilter(rawValue: newSec)!{
        case .deals:
            return FilterViewController.deals
        case .sort:
            return FilterViewController.sortBy
        case .distance:
            return FilterViewController.distance
       
        
        default: break
        }
        return FilterViewController.deals
     
    }
    
        
    
    func expandContractCell(indexPath:IndexPath)  {
        
        
        let totalRows = getArrayOnBasisOfSection(section: indexPath.section).count
        for row in 0 ..< totalRows {
            let modifyingIndexPath = IndexPath(row: row, section: ((indexPath as NSIndexPath).section))
            switchStatus[modifyingIndexPath] = false
        }
        isOpenStaus[indexPath.section] = !isOpenStaus[indexPath.section]
        switchStatus[indexPath] = !switchStatus[indexPath]!
        
        self.filterTableView.reloadData()
    }
    func getSelectedRowForOpening(indexPath:IndexPath)->Int
    {
        for (key, value) in switchStatus {
            print("\(key) -> \(value)")
        }
        print("section is \(indexPath.section)")
        switch sectionsFilter(rawValue: indexPath.section)!{
        
        case .sort,.distance:
            let totalRows = getArrayOnBasisOfSection(section: indexPath.section).count
            for row in 0 ..< totalRows {
                let modifyingIndexPath = IndexPath(row: row, section:indexPath.section)
                
                if(switchStatus[modifyingIndexPath] != nil){
                    if(switchStatus[modifyingIndexPath])!
                    {
                        print("Selectd row is \(row)")
                        return row
                    }
                    
                   
                }
            }
            return 0
        default:
            return 0
        }
             
    }
    
    func getSelectedDeal()->Bool{
        let indexPath = IndexPath(row: 0, section: sectionsFilter.deals.rawValue)
        if(switchStatus[indexPath] != nil){
            return switchStatus[indexPath]!
        }
        else{
             return false
        }
        
    }
    func getSelectedSort()->YelpSortMode{
        
        var sortMode = YelpSortMode.bestMatched
        let totalRows = getArrayOnBasisOfSection(section: sectionsFilter.sort.rawValue).count
        for row in 0 ..< totalRows {
            let modifyingIndexPath = IndexPath(row: row, section: sectionsFilter.sort.rawValue)
            if(switchStatus[modifyingIndexPath] != nil){
                if(switchStatus[modifyingIndexPath])!
                {
                    sortMode = YelpSortMode(rawValue: row)!
                }
            }
            
        }
       
        return sortMode
        
    }
    func getSelectedCategories()->[String]{
        
        var category = [String]()
        let totalRows = FilterViewController.categories.count
        for row in 0 ..< totalRows {
            let modifyingIndexPath = IndexPath(row: row, section: sectionsFilter.category.rawValue)
            if(switchStatus[modifyingIndexPath] != nil)
            {
                if(switchStatus[modifyingIndexPath])!
                {
                    category.append(FilterViewController.categories[row]["code"]!)
                }
            }
            
        }
        print("category is \(category)")
        return category
    }
    func getSelectedRadius()->Int{
        
        var radius = 0
        let totalRows = getArrayOnBasisOfSection(section: sectionsFilter.distance.rawValue).count
        for row in 0 ..< totalRows {
            let modifyingIndexPath = IndexPath(row: row, section: sectionsFilter.distance.rawValue)
            if(switchStatus[modifyingIndexPath] != nil)
            {
                if(switchStatus[modifyingIndexPath])!
                {
                    
                    radius = Int(FilterViewController.radiusInMeter(rawValue: row)!.doubleValue)
                    
                    
                }
            }
           
        }
        
        
        return radius
    }
}
extension FilterViewController
{
    @nonobjc static let oneMileToMeter = 1609.34
    enum sectionsFilter:Int {
        case deals,sort,distance,category
    }
    
  
    enum radiusInMeter: Int {
        case bestMatch
        case radius3
        case radiusOneMile
        case radiusFiveMiles
        case radiusTwentyMiles
        
        var doubleValue: Double {
            switch self {
            
            case .bestMatch: return 0.0
            case .radius3: return oneMileToMeter*0.3
            case .radiusOneMile: return  oneMileToMeter*1.0
            case .radiusFiveMiles: return oneMileToMeter*5.0
            case .radiusTwentyMiles: return oneMileToMeter*20.0
                
                
           
            }
        }
    }

    
    func getSectionName(sectionNumer: Int) -> String {
        switch sectionsFilter(rawValue: sectionNumer)!{
        case .deals:
                return ""
        case .sort:
                return "Sort by"
        case .distance:
                return "Distance"
        case .category :
                return "Category"
        }
        
    }
    func getRowCounts(sectionNumber:Int)->Int{
        switch sectionsFilter(rawValue: sectionNumber)!{
        case .deals:
            return  getArrayOnBasisOfSection(section: sectionNumber).count
        case .sort,.distance:
            if(isOpenStaus[sectionNumber])
            {
                return getArrayOnBasisOfSection(section: sectionNumber).count
            }
            else
            {
                return 1
            }
        
        case .category :
            if(isOpenStaus[sectionNumber])
            {
                return FilterViewController.categories.count
            }
            else
            {
                return 4
            }
        }
    }
    
    @nonobjc static let sortBy = ["Best Match","Distance","Rating"]
    @nonobjc static let distance = ["Best Match","0.3 miles","1 mile","5 miles","20 miles"]
    @nonobjc static let deals = ["Offering a Deal"]
    @nonobjc static let categories = [["name" : "Afghan", "code": "afghani"],
                                      ["name" : "African", "code": "african"],
                                      ["name" : "American, New", "code": "newamerican"],
                                      ["name" : "American, Traditional", "code": "tradamerican"],
                                      ["name" : "Arabian", "code": "arabian"],
                                      ["name" : "Argentine", "code": "argentine"],
                                      ["name" : "Armenian", "code": "armenian"],
                                      ["name" : "Asian Fusion", "code": "asianfusion"],
                                      ["name" : "Asturian", "code": "asturian"],
                                      ["name" : "Australian", "code": "australian"],
                                      ["name" : "Austrian", "code": "austrian"],
                                      ["name" : "Baguettes", "code": "baguettes"],
                                      ["name" : "Bangladeshi", "code": "bangladeshi"],
                                      ["name" : "Barbeque", "code": "bbq"],
                                      ["name" : "Basque", "code": "basque"],
                                      ["name" : "Bavarian", "code": "bavarian"],
                                      ["name" : "Beer Garden", "code": "beergarden"],
                                      ["name" : "Beer Hall", "code": "beerhall"],
                                      ["name" : "Beisl", "code": "beisl"],
                                      ["name" : "Belgian", "code": "belgian"],
                                      ["name" : "Bistros", "code": "bistros"],
                                      ["name" : "Black Sea", "code": "blacksea"],
                                      ["name" : "Brasseries", "code": "brasseries"],
                                      ["name" : "Brazilian", "code": "brazilian"],
                                      ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                                      ["name" : "British", "code": "british"],
                                      ["name" : "Buffets", "code": "buffets"],
                                      ["name" : "Bulgarian", "code": "bulgarian"],
                                      ["name" : "Burgers", "code": "burgers"],
                                      ["name" : "Burmese", "code": "burmese"],
                                      ["name" : "Cafes", "code": "cafes"],
                                      ["name" : "Cafeteria", "code": "cafeteria"],
                                      ["name" : "Cajun/Creole", "code": "cajun"],
                                      ["name" : "Cambodian", "code": "cambodian"],
                                      ["name" : "Canadian", "code": "New)"],
                                      ["name" : "Canteen", "code": "canteen"],
                                      ["name" : "Caribbean", "code": "caribbean"],
                                      ["name" : "Catalan", "code": "catalan"],
                                      ["name" : "Chech", "code": "chech"],
                                      ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                                      ["name" : "Chicken Shop", "code": "chickenshop"],
                                      ["name" : "Chicken Wings", "code": "chicken_wings"],
                                      ["name" : "Chilean", "code": "chilean"],
                                      ["name" : "Chinese", "code": "chinese"],
                                      ["name" : "Comfort Food", "code": "comfortfood"],
                                      ["name" : "Corsican", "code": "corsican"],
                                      ["name" : "Creperies", "code": "creperies"],
                                      ["name" : "Cuban", "code": "cuban"],
                                      ["name" : "Curry Sausage", "code": "currysausage"],
                                      ["name" : "Cypriot", "code": "cypriot"],
                                      ["name" : "Czech", "code": "czech"],
                                      ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                                      ["name" : "Danish", "code": "danish"],
                                      ["name" : "Delis", "code": "delis"],
                                      ["name" : "Diners", "code": "diners"],
                                      ["name" : "Dumplings", "code": "dumplings"],
                                      ["name" : "Eastern European", "code": "eastern_european"],
                                      ["name" : "Ethiopian", "code": "ethiopian"],
                                      ["name" : "Fast Food", "code": "hotdogs"],
                                      ["name" : "Filipino", "code": "filipino"],
                                      ["name" : "Fish & Chips", "code": "fishnchips"],
                                      ["name" : "Fondue", "code": "fondue"],
                                      ["name" : "Food Court", "code": "food_court"],
                                      ["name" : "Food Stands", "code": "foodstands"],
                                      ["name" : "French", "code": "french"],
                                      ["name" : "French Southwest", "code": "sud_ouest"],
                                      ["name" : "Galician", "code": "galician"],
                                      ["name" : "Gastropubs", "code": "gastropubs"],
                                      ["name" : "Georgian", "code": "georgian"],
                                      ["name" : "German", "code": "german"],
                                      ["name" : "Giblets", "code": "giblets"],
                                      ["name" : "Gluten-Free", "code": "gluten_free"],
                                      ["name" : "Greek", "code": "greek"],
                                      ["name" : "Halal", "code": "halal"],
                                      ["name" : "Hawaiian", "code": "hawaiian"],
                                      ["name" : "Heuriger", "code": "heuriger"],
                                      ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                                      ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                                      ["name" : "Hot Dogs", "code": "hotdog"],
                                      ["name" : "Hot Pot", "code": "hotpot"],
                                      ["name" : "Hungarian", "code": "hungarian"],
                                      ["name" : "Iberian", "code": "iberian"],
                                      ["name" : "Indian", "code": "indpak"],
                                      ["name" : "Indonesian", "code": "indonesian"],
                                      ["name" : "International", "code": "international"],
                                      ["name" : "Irish", "code": "irish"],
                                      ["name" : "Island Pub", "code": "island_pub"],
                                      ["name" : "Israeli", "code": "israeli"],
                                      ["name" : "Italian", "code": "italian"],
                                      ["name" : "Japanese", "code": "japanese"],
                                      ["name" : "Jewish", "code": "jewish"],
                                      ["name" : "Kebab", "code": "kebab"],
                                      ["name" : "Korean", "code": "korean"],
                                      ["name" : "Kosher", "code": "kosher"],
                                      ["name" : "Kurdish", "code": "kurdish"],
                                      ["name" : "Laos", "code": "laos"],
                                      ["name" : "Laotian", "code": "laotian"],
                                      ["name" : "Latin American", "code": "latin"],
                                      ["name" : "Live/Raw Food", "code": "raw_food"],
                                      ["name" : "Lyonnais", "code": "lyonnais"],
                                      ["name" : "Malaysian", "code": "malaysian"],
                                      ["name" : "Meatballs", "code": "meatballs"],
                                      ["name" : "Mediterranean", "code": "mediterranean"],
                                      ["name" : "Mexican", "code": "mexican"],
                                      ["name" : "Middle Eastern", "code": "mideastern"],
                                      ["name" : "Milk Bars", "code": "milkbars"],
                                      ["name" : "Modern Australian", "code": "modern_australian"],
                                      ["name" : "Modern European", "code": "modern_european"],
                                      ["name" : "Mongolian", "code": "mongolian"],
                                      ["name" : "Moroccan", "code": "moroccan"],
                                      ["name" : "New Zealand", "code": "newzealand"],
                                      ["name" : "Night Food", "code": "nightfood"],
                                      ["name" : "Norcinerie", "code": "norcinerie"],
                                      ["name" : "Open Sandwiches", "code": "opensandwiches"],
                                      ["name" : "Oriental", "code": "oriental"],
                                      ["name" : "Pakistani", "code": "pakistani"],
                                      ["name" : "Parent Cafes", "code": "eltern_cafes"],
                                      ["name" : "Parma", "code": "parma"],
                                      ["name" : "Persian/Iranian", "code": "persian"],
                                      ["name" : "Peruvian", "code": "peruvian"],
                                      ["name" : "Pita", "code": "pita"],
                                      ["name" : "Pizza", "code": "pizza"],
                                      ["name" : "Polish", "code": "polish"],
                                      ["name" : "Portuguese", "code": "portuguese"],
                                      ["name" : "Potatoes", "code": "potatoes"],
                                      ["name" : "Poutineries", "code": "poutineries"],
                                      ["name" : "Pub Food", "code": "pubfood"],
                                      ["name" : "Rice", "code": "riceshop"],
                                      ["name" : "Romanian", "code": "romanian"],
                                      ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                                      ["name" : "Rumanian", "code": "rumanian"],
                                      ["name" : "Russian", "code": "russian"],
                                      ["name" : "Salad", "code": "salad"],
                                      ["name" : "Sandwiches", "code": "sandwiches"],
                                      ["name" : "Scandinavian", "code": "scandinavian"],
                                      ["name" : "Scottish", "code": "scottish"],
                                      ["name" : "Seafood", "code": "seafood"],
                                      ["name" : "Serbo Croatian", "code": "serbocroatian"],
                                      ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                                      ["name" : "Singaporean", "code": "singaporean"],
                                      ["name" : "Slovakian", "code": "slovakian"],
                                      ["name" : "Soul Food", "code": "soulfood"],
                                      ["name" : "Soup", "code": "soup"],
                                      ["name" : "Southern", "code": "southern"],
                                      ["name" : "Spanish", "code": "spanish"],
                                      ["name" : "Steakhouses", "code": "steak"],
                                      ["name" : "Sushi Bars", "code": "sushi"],
                                      ["name" : "Swabian", "code": "swabian"],
                                      ["name" : "Swedish", "code": "swedish"],
                                      ["name" : "Swiss Food", "code": "swissfood"],
                                      ["name" : "Tabernas", "code": "tabernas"],
                                      ["name" : "Taiwanese", "code": "taiwanese"],
                                      ["name" : "Tapas Bars", "code": "tapas"],
                                      ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                                      ["name" : "Tex-Mex", "code": "tex-mex"],
                                      ["name" : "Thai", "code": "thai"],
                                      ["name" : "Traditional Norwegian", "code": "norwegian"],
                                      ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                                      ["name" : "Trattorie", "code": "trattorie"],
                                      ["name" : "Turkish", "code": "turkish"],
                                      ["name" : "Ukrainian", "code": "ukrainian"],
                                      ["name" : "Uzbek", "code": "uzbek"],
                                      ["name" : "Vegan", "code": "vegan"],
                                      ["name" : "Vegetarian", "code": "vegetarian"],
                                      ["name" : "Venison", "code": "venison"],
                                      ["name" : "Vietnamese", "code": "vietnamese"],
                                      ["name" : "Wok", "code": "wok"],
                                      ["name" : "Wraps", "code": "wraps"],
                                      ["name" : "Yugoslav", "code": "yugoslav"]]

    
    
    
    
}
