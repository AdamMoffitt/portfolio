import UIKit
import Alamofire
import AlamofireImage

class SearchResultCell: UITableViewCell {
    
    var resultImage:UIImageView!
    var resultText:UILabel!
    var tickerText: UILabel!
    var imageString:String!
    var textString:String!
    var company:Bool!
    var companyTicker:String!
    var placeHolder:String!
    
    override func prepareForReuse() {
        resultImage?.removeFromSuperview()
        resultText?.removeFromSuperview()
        tickerText?.removeFromSuperview()
    }
    
    func createImage(){
        resultImage = UIImageView()
        resultImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.height * 0.5, height: contentView.bounds.height * 0.5)
        resultImage.contentMode = UIViewContentMode.scaleAspectFit
        resultImage.layer.cornerRadius = 10
        resultImage.clipsToBounds = true
        resultImage.layer.masksToBounds = true
        resultImage.translatesAutoresizingMaskIntoConstraints = false
        resultImage.layer.borderWidth = 1
        resultImage.layer.borderColor = UIColor.white.cgColor
        resultImage.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        contentView.addSubview(resultImage)
    }
    
    func setImage(url: String){
        if url != "" {
            let imageUrl:URL = URL(string: url)!
            resultImage.af_setImage(withURL: imageUrl, placeholderImage: UIImage(named: placeHolder))
        } else {
            resultImage.image = UIImage(named: placeHolder)
        }
    }
    
    func createTickerLabel(){
        tickerText = UILabel()
        tickerText.text = companyTicker
        tickerText.textColor = UIColor.white
        tickerText.translatesAutoresizingMaskIntoConstraints = false
        tickerText.font = UIFont.boldSystemFont(ofSize: 8)
        tickerText.numberOfLines = 0
        contentView.addSubview(tickerText)
    }
    
    func createDescriptionLabel(){
        resultText = UILabel()
        resultText.text = textString
        resultText.textColor = UIColor.white
        resultText.translatesAutoresizingMaskIntoConstraints = false
        resultText.font = UIFont.boldSystemFont(ofSize: 14)
        resultText.numberOfLines = 0
        resultText.tag = 1
        contentView.addSubview(resultText)
    }
    
    func setConstraints(){
        let margins = contentView.layoutMarginsGuide
        resultImage.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        resultImage.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 1.2).isActive = true
        resultImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        resultImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        if(company){
            tickerText.centerXAnchor.constraint(equalTo: resultImage.centerXAnchor).isActive = true
            tickerText.topAnchor.constraintEqualToSystemSpacingBelow(resultImage.bottomAnchor, multiplier: 1.1).isActive = true
        }
        resultText.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.85).isActive = true
        resultText.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        resultText.leadingAnchor.constraintEqualToSystemSpacingAfter(resultImage.trailingAnchor, multiplier: 1.1).isActive = true
    }
    
    func setupViews(text: String, image: String, isCompany: Bool, ticker: String, url: String, placeholder: String){
        self.placeHolder = placeholder
        textString = text
        imageString = image
        company = isCompany
        companyTicker = ticker
        
        if(company){
            createTickerLabel()
        }
        createImage()
        setImage(url: url)
        createDescriptionLabel()
        setConstraints()
    }
    
    func updateViews(text: String, image: String, isCompany: Bool, ticker: String, url: String, placeholder: String){
        self.placeHolder = placeholder
        resultText.text = text
        //Clear prior image (having cell reuse problem)
        resultImage = nil
        imageString = image
        
        if(company){
            tickerText.text = ticker
        }
        createImage()
        setImage(url: url)
        setConstraints()
    }
    
}
