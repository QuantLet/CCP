classdef PortfolioDiversification
    properties
        PortfolioWeights
        NumAssets
        AssetReturns
        AssetCovar
        DispersionMeasure
        DiversificationFunction
        WeightsDistributionEntropy
        MarginalRiskContributions
        MarginalRiskContributionsEntropy
        DiversificationDistribution_PCA
        ENB_PCA
        DiversificationDistribution_MT
        ENB_MT
        Diversification_Delta
        N_Eff_DiversificationReturn
        N_Eff_PortfolioVariance
        DiversificationRatio
        PDI
        
    end
   methods
        function pd=PortfolioDiversification(varargin)
            prop={'PortfolioWeights';'AssetReturns';'AssetCovar';'DiversificationFunction'};
            for i=1:length(varargin)
                c{i}=class(varargin{i});
                if strmatch(c{i},'char')==1
                    if isempty(strmatch(varargin{i},prop)==1)==0
                        switch varargin{i}
                            case 'PortfolioWeights'
                                pd.PortfolioWeights=varargin{i+1};
                                pd.NumAssets=size(pd.PortfolioWeights,1);
                            case 'AssetReturns'
                                pd.AssetReturns=varargin{i+1};
                            case 'AssetCovar'
                                pd.AssetCovar=varargin{i+1};
                            case 'DispersionMeasure'
                                pd.DispersionMeasure=varargin{i+1};
                            case 'DiversificationFunction'
                                pd.DiversificationFunction=varargin{i+1};
                        end
                    end
                end
            end
        end
        function [pd]=MeasureDiversification(pd)
            for z=1:length(pd.DiversificationFunction)
                for h=1:size(pd.PortfolioWeights,2)
                    switch pd.DiversificationFunction{z}
                        case 'Weights'
                            pd.WeightsDistributionEntropy(h)=exp(-sum(pd.PortfolioWeights(:,h).*log(1+(pd.PortfolioWeights(:,h)-1).*(pd.PortfolioWeights(:,h)>1e-5))));
                            pd.DispersionMeasure{z}='Shannon entropy';
                        case 'Marginal Risk Contributions'
                            pd.MarginalRiskContributions(:,h) =  pd.PortfolioWeights(:,h).*(pd.AssetCovar * pd.PortfolioWeights(:,h))/( pd.PortfolioWeights(:,h)'*pd.AssetCovar* pd.PortfolioWeights(:,h));
                            pd.MarginalRiskContributionsEntropy(h)=exp(-sum(pd.MarginalRiskContributions(:,h).*log(1+(pd.MarginalRiskContributions(:,h)-1).*(pd.MarginalRiskContributions(:,h)>1e-5))));
                            pd.DispersionMeasure{z}='Shannon entropy';
                        case 'ENB_PCA'
                            t = torsion(pd.AssetCovar, 'pca', 'exact', 1000);
                            [pd.ENB_PCA(h), pd.DiversificationDistribution_PCA(:,h)] = EffectiveBets(pd.PortfolioWeights(:,h), pd.AssetCovar, t);
                            pd.DispersionMeasure{z}='Shannon entropy';
                        case 'ENB_MT'
                            t = torsion(pd.AssetCovar, 'minimum-torsion', 'exact', 1000);
                            [pd.ENB_MT(h), pd.DiversificationDistribution_MT(:,h)] = EffectiveBets(pd.PortfolioWeights(:,h), pd.AssetCovar, t);
                            pd.DispersionMeasure{z}='Shannon entropy';
                        case 'Diversification Delta'
                            [H]=DiversificationDelta(pd.AssetReturns);
                            pd.Diversification_Delta(h)=(exp(pd.PortfolioWeights(:,h)'*H)-exp(DiversificationDelta(pd.AssetReturns*pd.PortfolioWeights(:,h))))/exp(pd.PortfolioWeights(:,h)'*H);
                            pd.DispersionMeasure{z}='Shannon entropy';
                        case 'Diversification Return'
                            d=zeros(size(pd.AssetCovar));
                            for i=1:pd.NumAssets
                                for j=1:pd.NumAssets
                                    d(i,j)=pd.AssetCovar(i,i)+pd.AssetCovar(j,j)-2*pd.AssetCovar(i,j);
                                end
                            end
                            d = (d-min(d(:)))/(max(d(:))-min(d(:)));
                            H=(0.5*(pd.PortfolioWeights(:,h)'*d*pd.PortfolioWeights(:,h)));
                            pd.N_Eff_DiversificationReturn(h)=1/(1-2*H);
                            pd.DispersionMeasure{z}='Rao quadratic entropy';
                        case 'Portfolio Variance'
                            Omega=corrcoef(pd.AssetCovar);
                            d=zeros(size(pd.AssetCovar));
                            for i=1:pd.NumAssets
                                for j=1:pd.NumAssets
                                    d(i,j)=2*(1-Omega(i,j));
                                end
                            end
                            d = (d-min(d(:)))/(max(d(:))-min(d(:)));
                            H=(0.5*(pd.PortfolioWeights(:,h)'*d*pd.PortfolioWeights(:,h)));
                            pd.N_Eff_PortfolioVariance(h)=1/(1-2*H);
                            pd.DispersionMeasure{z}='Rao quadratic entropy';
                        case 'Diversification Ratio'
                            pd.DiversificationRatio(h)=(pd.PortfolioWeights(:,h)'*sqrt(diag(pd.AssetCovar)))/sqrt(pd.PortfolioWeights(:,h)'*pd.AssetCovar*pd.PortfolioWeights(:,h));
                            pd.DispersionMeasure{z}='none';
                        case 'Portfolio Diversification Index'
                            ScaledReturns=zeros(size(pd.AssetReturns));
                            for i=1:length(pd.PortfolioWeights(:,h));
                                ScaledReturns(:,i)=pd.AssetReturns(:,i)/(1-pd.PortfolioWeights(i,h));
                            end
                            lambda=eig(nancov(ScaledReturns));
                            strength=sort(lambda/sum(lambda),'descend');
                            pd.PDI(h)=sum(strength'.*(1:pd.NumAssets))*2-1;
                            pd.DispersionMeasure{z}='none';
                    end
                end
            end
        end
        function [pd,weights]=MaxDiversificationPortfolio(pd,ub)
            w=ones(pd.NumAssets,1)/pd.NumAssets;
            Constr.Aeq=ones(1,pd.NumAssets); % budget constraint.
            Constr.beq=1;
            %ub=ones(pd.NumAssets);
            lb=zeros(pd.NumAssets,1);
            weights=zeros(pd.NumAssets,length(pd.DiversificationFunction));
            for i=1:length(pd.DiversificationFunction)
                [weights(:,i)]=fmincon(@(w)MaxDiversification(w,pd.AssetCovar,pd.AssetReturns,pd.DiversificationFunction(i)),w,[],[],Constr.Aeq,Constr.beq,lb,ub,[]);
            end
        end
        
    end
end
